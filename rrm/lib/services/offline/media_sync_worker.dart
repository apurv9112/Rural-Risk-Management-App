import 'dart:io';
import 'package:crypto/crypto.dart';
import 'media_transport_service.dart';
import 'queue_models.dart';
import 'transport_exceptions.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'auth_recovery_service.dart';

class MediaSyncWorker {
  final MediaTransportService transportService;
  final SyncQueueRepository syncQueueRepository;
  final MediaQueueRepository mediaQueueRepository;
  final AuthRecoveryService authRecoveryService;
  static const int chunkSize = 5 * 1024 * 1024; // 5MB

  MediaSyncWorker({
    required this.transportService,
    required this.syncQueueRepository,
    required this.mediaQueueRepository,
    required this.authRecoveryService,
  });

  Future<void> processMedia(String mediaId) async {
    final media = await mediaQueueRepository.getById(mediaId);
    if (media == null) return;

    if (media.state == MediaState.COMPLETED) return;
    if (media.state == MediaState.FAILED) return;

    // Transition PENDING -> UPLOADING
    await _updateState(media, MediaState.UPLOADING);

    File file = File(media.filePath);
    if (!await file.exists()) {
      await _updateState(media, MediaState.FAILED);
      return;
    }

    // SHA256 Calculation
    if (media.checksum == null) {
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      media.checksum = digest.toString();
      await mediaQueueRepository.update(media);
    }

    // Determine MIME type simply based on extension
    String mimeType = 'application/octet-stream';
    if (media.filePath.toLowerCase().endsWith('.jpg') || media.filePath.toLowerCase().endsWith('.jpeg')) {
      mimeType = 'image/jpeg';
    } else if (media.filePath.toLowerCase().endsWith('.mp4')) {
      mimeType = 'video/mp4';
    } else if (media.filePath.toLowerCase().endsWith('.pdf')) {
      mimeType = 'application/pdf';
    }

    // Transition UPLOADING -> INIT
    await _updateState(media, MediaState.INIT);

    if (media.remoteUploadId == null) {
      try {
        final initResult = await transportService.initUpload(
          checksum: media.checksum!,
          fileSize: media.totalSizeBytes,
          mimeType: mimeType,
        );

        if (!initResult.success) {
          if (initResult.isFileMissing) {
            await _updateState(media, MediaState.FAILED);
          } else {
            await _updateState(media, MediaState.RETRY_PENDING);
          }
          return;
        }
        media.remoteUploadId = initResult.uploadId;
        await mediaQueueRepository.update(media);
      } catch (e) {
        if (!await _handleTransportException(e, media)) {
          return;
        }
        await _updateState(media, MediaState.RETRY_PENDING);
        return;
      }
    }

    // Transition INIT -> CHUNK LOOP
    await _updateState(media, MediaState.CHUNK_LOOP);

    RandomAccessFile raf = await file.open(mode: FileMode.read);
    try {
      while (media.uploadedBytes < media.totalSizeBytes) {
        int remaining = media.totalSizeBytes - media.uploadedBytes;
        int currentChunkSize = remaining < chunkSize ? remaining : chunkSize;
        
        await raf.setPosition(media.uploadedBytes);
        List<int> chunkData = await raf.read(currentChunkSize);
        int chunkIndex = media.uploadedBytes ~/ chunkSize;

        bool chunkSuccess = false;
        while (!chunkSuccess) {
          try {
            print('[MediaSyncWorker] Uploading chunk $chunkIndex (${chunkData.length} bytes) for media $mediaId (Total uploaded: ${media.uploadedBytes}/${media.totalSizeBytes})');
            final chunkResult = await transportService.uploadChunk(
              uploadId: media.remoteUploadId!,
              chunkIndex: chunkIndex,
              bytes: chunkData,
            );

            if (!chunkResult.success) {
              if (chunkResult.shouldRetry) {
                await _updateState(media, MediaState.RETRY_PENDING);
              } else {
                await _updateState(media, MediaState.FAILED);
              }
              return; 
            }
            chunkSuccess = true;
          } catch (e) {
            if (e is AuthenticationException) {
              bool refreshed = await authRecoveryService.refreshToken();
              if (refreshed) {
                // Retry same chunk without resetting state!
                continue;
              } else {
                await _updateState(media, MediaState.FAILED);
                return;
              }
            } else if (e is ForbiddenException) {
              await _updateState(media, MediaState.FAILED);
              return;
            } else if (e is RateLimitException || e is ServerException || e is TimeoutException || e is NetworkException) {
              await _updateState(media, MediaState.RETRY_PENDING);
              return;
            } else {
              await _updateState(media, MediaState.FAILED);
              return;
            }
          }
        }

        media.uploadedBytes += currentChunkSize;
        print('[MediaSyncWorker] Chunk $chunkIndex successful. Total uploaded: ${media.uploadedBytes}/${media.totalSizeBytes}');
        await mediaQueueRepository.update(media);
      }
    } finally {
      await raf.close();
    }

    // Transition CHUNK LOOP -> COMPLETE
    await _updateState(media, MediaState.COMPLETE);

    try {
      final completeResult = await transportService.completeUpload(
        uploadId: media.remoteUploadId!,
        checksum: media.checksum!,
      );
      if (!completeResult.success) {
        await _updateState(media, MediaState.FAILED);
        return;
      }
      media.remoteAssetId = completeResult.assetId;
    } catch (e) {
      if (e is AuthenticationException) {
        bool refreshed = await authRecoveryService.refreshToken();
        if (refreshed) {
           await _updateState(media, MediaState.RETRY_PENDING); 
           return;
        } else {
           await _updateState(media, MediaState.FAILED);
           return;
        }
      } else {
        await _updateState(media, MediaState.FAILED);
        return;
      }
    }
    
    // Transition COMPLETE -> COMPLETED
    await _updateState(media, MediaState.COMPLETED);

    // Parent release validation
    await _checkParentEligibility(media.syncQueueId);
  }

  Future<bool> _handleTransportException(Object e, MediaQueue media) async {
    if (e is AuthenticationException) {
      return true; // Indicates it could potentially refresh
    } else if (e is ForbiddenException) {
      await _updateState(media, MediaState.FAILED);
      return false;
    } else if (e is RateLimitException || e is ServerException || e is TimeoutException || e is NetworkException) {
      await _updateState(media, MediaState.RETRY_PENDING);
      return false;
    }
    await _updateState(media, MediaState.FAILED);
    return false;
  }

  Future<void> _updateState(MediaQueue media, MediaState newState) async {
      print('[MediaSyncWorker] Media ${media.id} transitioning state: ${media.state.name} -> ${newState.name}');
    media.state = newState;
    await mediaQueueRepository.update(media);
  }

  Future<void> _checkParentEligibility(String syncQueueId) async {
    final mediaItems = await mediaQueueRepository.getBySyncQueueId(syncQueueId);
    
    bool allValid = true;
    for (final m in mediaItems) {
      if (m.state != MediaState.COMPLETED || m.remoteAssetId == null) {
        allValid = false;
        break;
      }
    }

    if (allValid) {
      final syncQueue = await syncQueueRepository.getById(syncQueueId);
      if (syncQueue != null) {
        print('[MediaSyncWorker] All media completed. Parent SyncQueue $syncQueueId is now ELIGIBLE_FOR_SYNC.');
        syncQueue.state = SyncState.ELIGIBLE_FOR_SYNC;
        await syncQueueRepository.update(syncQueue);
      }
    }
  }
}
