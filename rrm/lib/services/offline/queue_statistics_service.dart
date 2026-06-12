import 'package:get/get.dart';
import 'package:rrm/services/offline/queue_models.dart';
import 'dart:async';

import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';

class QueueStatisticsService extends GetxService {
  final SyncQueueRepository syncQueueRepository;
  final MediaQueueRepository mediaQueueRepository;

  // Media Metrics
  final pendingMediaCount = 0.obs;
  final uploadingMediaCount = 0.obs;
  final failedMediaCount = 0.obs;
  final completedMediaCount = 0.obs;

  // Sync Record Metrics
  final pendingSyncCount = 0.obs;
  final syncingSyncCount = 0.obs;
  final failedSyncCount = 0.obs;
  final completedSyncCount = 0.obs;

  // General Metrics
  final totalQueueSizeBytes = 0.obs;
  final lastSuccessfulSyncTime = Rxn<DateTime>();
  final lastFailedSyncTime = Rxn<DateTime>();

  // Queue Health Audit properties
  final orphanMediaCount = 0.obs;
  final staleLocksCount = 0.obs;


  QueueStatisticsService({
    required this.syncQueueRepository,
    required this.mediaQueueRepository,
  });

  @override
  void onInit() {
    super.onInit();
    refreshMetrics();
  }


  Future<void> refreshMetrics() async {
    int pMedia = 0;
    int uMedia = 0;
    int fMedia = 0;
    int cMedia = 0;
    int totalBytes = 0;

    int oCount = 0;
    int sCount = 0;

    final mediaQueues = await mediaQueueRepository.getAll();
    final syncQueuesList = await syncQueueRepository.getAll();
    final syncQueueIds = syncQueuesList.map((s) => s.id).toSet();

    for (var m in mediaQueues) {
      if (m.state == MediaState.PENDING) {
        pMedia++;
      } else if (m.state == MediaState.UPLOADING || m.state == MediaState.INIT || m.state == MediaState.CHUNK_LOOP || m.state == MediaState.COMPLETE) {
        uMedia++;
      } else if (m.state == MediaState.FAILED) {
        fMedia++;
      } else if (m.state == MediaState.COMPLETED) {
        cMedia++;
      }

      if (m.state != MediaState.COMPLETED) {
        totalBytes += (m.totalSizeBytes - m.uploadedBytes);
      }

      if (!syncQueueIds.contains(m.syncQueueId)) {
        oCount++;
      }
      
      if (m.state == MediaState.UPLOADING || m.state == MediaState.CHUNK_LOOP) {
        sCount++;
      }
    }

    pendingMediaCount.value = pMedia;
    uploadingMediaCount.value = uMedia;
    failedMediaCount.value = fMedia;
    completedMediaCount.value = cMedia;
    totalQueueSizeBytes.value = totalBytes;
    
    orphanMediaCount.value = oCount;
    staleLocksCount.value = sCount;

    int pSync = 0;
    int uSync = 0;
    int fSync = 0; 
    int cSync = 0;

    for (var s in syncQueuesList) {
      if (s.state == SyncState.PENDING || s.state == SyncState.ELIGIBLE_FOR_SYNC) {
        pSync++;
      } else if (s.state == SyncState.UPLOADING_MEDIA) {
        uSync++;
      } else if (s.state == SyncState.COMPLETED) {
        cSync++;
      }
    }

    pendingSyncCount.value = pSync;
    syncingSyncCount.value = uSync;
    failedSyncCount.value = fSync; 
    completedSyncCount.value = cSync;
  }

  void recordSyncSuccess() {
    lastSuccessfulSyncTime.value = DateTime.now();
  }

  void recordSyncFailure() {
    lastFailedSyncTime.value = DateTime.now();
  }
  
  String get queueIntegrityStatus {
    if (orphanMediaCount.value > 0) return 'Critical';
    if (staleLocksCount.value > 0) return 'Warning';
    return 'Healthy';
  }
}
