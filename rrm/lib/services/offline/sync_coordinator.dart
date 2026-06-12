
import 'media_sync_worker.dart';
import 'queue_processor.dart';
import 'sync_status_service.dart';
import 'queue_models.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';

class SyncCoordinator {
  final MediaSyncWorker mediaSyncWorker;
  final QueueProcessor queueProcessor;
  final SyncStatusService syncStatusService;
  final SyncQueueRepository syncQueueRepository;
  final MediaQueueRepository mediaQueueRepository;

  bool _isSyncing = false;

  SyncCoordinator({
    required this.mediaSyncWorker,
    required this.queueProcessor,
    required this.syncStatusService,
    required this.syncQueueRepository,
    required this.mediaQueueRepository,
  });

  Future<void> init() async {
    // 1. Recover any stale locks left over from a previous crash
    await recoverStaleLocks();
    
    // 2. Perform an initial sync check if needed
    // In a real app we'd check connectivity first.
    await _executeSyncIfNeeded();
  }

  Future<void> recoverStaleLocks() async {
    final mediaItems = await mediaQueueRepository.getByStates([
      MediaState.UPLOADING,
      MediaState.INIT,
      MediaState.CHUNK_LOOP
    ]);
    for (final media in mediaItems) {
      print('[SyncCoordinator] Recovering stale lock for MediaQueue: ${media.id}');
      media.state = MediaState.PENDING;
      await mediaQueueRepository.update(media);
    }
    
    final syncQueues = await syncQueueRepository.getByStates([
      SyncState.UPLOADING_MEDIA
    ]);
    for (final queue in syncQueues) {
      print('[SyncCoordinator] Recovering stale lock for SyncQueue: ${queue.id}');
      queue.state = SyncState.PENDING;
      await syncQueueRepository.update(queue);
    }
  }

  Future<void> requestManualSync() async {
    await _executeSyncIfNeeded();
  }

  Future<void> onNetworkAvailable() async {
    await _executeSyncIfNeeded();
  }

  Future<void> _executeSyncIfNeeded() async {
    if (_isSyncing) {
      // Collision prevented
      return;
    }

    _isSyncing = true;
    try {
      print('[SyncCoordinator] Starting sync process...');
      syncStatusService.setStatus(SyncStateStatus.syncingMedia);

      // 1. Process all pending media
      // Fetch all EXCEPT COMPLETED
      final allMedia = await mediaQueueRepository.getAll();
      final pendingMedia = allMedia.where((m) => m.state != MediaState.COMPLETED).toList();
      print('[SyncCoordinator] Found ${pendingMedia.length} pending media items.');
          
      for (final media in pendingMedia) {
        await mediaSyncWorker.processMedia(media.id);
      }

      print('[SyncCoordinator] Media sync finished. Starting payload sync...');
      syncStatusService.setStatus(SyncStateStatus.syncingRecords);

      // 2. Process all eligible sync queues
      await queueProcessor.processAllPendingSyncQueues();

      print('[SyncCoordinator] Sync process completed successfully.');
      syncStatusService.setStatus(SyncStateStatus.completed);
    } catch (e) {
      print('[SyncCoordinator] Sync process failed: $e');
      syncStatusService.setStatus(SyncStateStatus.failed);
    } finally {
      _isSyncing = false;
      // Reset back to idle after a brief delay
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isSyncing) {
          syncStatusService.setStatus(SyncStateStatus.idle);
        }
      });
    }
  }
  
  bool get isSyncing => _isSyncing;

  Future<void> retryFailedQueue(String syncQueueId) async {
    final mediaItems = await mediaQueueRepository.getBySyncQueueId(syncQueueId);
    bool shouldSync = false;
    for (var m in mediaItems) {
      if (m.state == MediaState.FAILED) {
        m.state = MediaState.PENDING;
        await mediaQueueRepository.update(m);
        shouldSync = true;
      }
    }
    if (shouldSync) {
      await requestManualSync();
    }
  }

  Future<void> retryAllFailed() async {
    bool shouldSync = false;
    final failedMedia = await mediaQueueRepository.getByStates([MediaState.FAILED]);
    for (var m in failedMedia) {
      m.state = MediaState.PENDING;
      await mediaQueueRepository.update(m);
      shouldSync = true;
    }
    if (shouldSync) {
      await requestManualSync();
    }
  }
}
