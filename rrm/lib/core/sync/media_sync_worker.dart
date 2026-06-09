import 'dart:async';
import 'dart:io';

import '../../data/repositories/media_queue_repository.dart';

class MediaSyncWorker {
  final MediaQueueRepository repository;
  bool _isRunning = false;

  // Injection for testing
  bool testInjectTimeout = false;
  bool testInjectMissingFile = false;

  MediaSyncWorker({required this.repository});

  Future<void> initialize() async {
    // Phase 4: Stale Lock Recovery on startup
    final recovered = await repository.recoverStaleLocks(30);
    print("MediaSyncWorker: Recovered $recovered stale locks.");
  }

  Future<void> processQueue({bool singleRun = false}) async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      while (true) {
        final media = await repository.getNextPendingMedia();
        if (media == null) {
          break; // Queue is empty or all are UPLOADING
        }

        final mediaUuid = media['media_uuid'] as String;
        
        // Phase 3: Atomic Claim Lock
        final claimed = await repository.claimMediaForUpload(mediaUuid);
        if (!claimed) {
          continue; // Another worker instance grabbed it
        }

        await _uploadMedia(media);

        if (singleRun) break;
      }
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _uploadMedia(Map<String, dynamic> media) async {
    final mediaUuid = media['media_uuid'] as String;
    
    try {
      if (testInjectMissingFile) {
        throw const FileSystemException("File not found");
      }
      if (testInjectTimeout) {
        throw TimeoutException("Synthetic timeout");
      }

      // Simulate network upload
      await Future.delayed(const Duration(milliseconds: 100));

      // Phase 1: Synthetic Asset ID
      final assetId = "mock_asset_$mediaUuid";
      
      await repository.markCompleted(mediaUuid, assetId);

    } on FileSystemException catch (e) {
      // Phase 6: Terminal failure
      await repository.markFailed(mediaUuid, e.toString(), isTerminal: true);
    } on TimeoutException catch (e) {
      // Phase 6: Retryable failure
      await repository.markFailed(mediaUuid, e.toString(), isTerminal: false);
    } catch (e) {
      // General retryable
      await repository.markFailed(mediaUuid, e.toString(), isTerminal: false);
    }
  }
}
