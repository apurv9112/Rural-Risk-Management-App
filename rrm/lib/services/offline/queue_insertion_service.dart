import 'dart:io';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'queue_models.dart';

class QueueInsertionService {
  final SyncQueueRepository syncQueueRepository;
  final MediaQueueRepository mediaQueueRepository;

  QueueInsertionService({
    required this.syncQueueRepository,
    required this.mediaQueueRepository,
  });

  /// Inserts a generic payload containing a mix of JSON fields and File objects.
  /// Automatically partitions Files into `media_queue` and the rest into `sync_queue`.
  Future<String> enqueuePayload(Map<String, dynamic> rawPayload, {required String endpoint}) async {
    final String syncQueueId = 'sync_${DateTime.now().microsecondsSinceEpoch}';
    
    final Map<String, dynamic> jsonPayload = {};
    final List<MediaQueue> mediaTasks = [];
    
    rawPayload.forEach((key, value) {
      if (value is File) {
        mediaTasks.add(_createMediaQueue(syncQueueId, key, value));
      } else if (value is List) {
        // Handle array of files
        if (value.isNotEmpty && value.first is File) {
          for (int i = 0; i < value.length; i++) {
            mediaTasks.add(_createMediaQueue(syncQueueId, key, value[i] as File, arrayIndex: i));
          }
        } else {
          // Standard JSON array
          jsonPayload[key] = value;
        }
      } else {
        // Standard JSON primitive
        jsonPayload[key] = value;
      }
    });

    final syncQueue = SyncQueue(
      id: syncQueueId,
      state: SyncState.PENDING,
      payload: jsonPayload,
    );
    // Add endpoint or tag to payload if needed by transport later.
    jsonPayload['_endpoint'] = endpoint;

    await syncQueueRepository.insert(syncQueue);
    
    for (var media in mediaTasks) {
      await mediaQueueRepository.insert(media);
    }

    return syncQueueId;
  }

  MediaQueue _createMediaQueue(String syncQueueId, String fieldName, File file, {int? arrayIndex}) {
    final String mediaId = 'media_${DateTime.now().microsecondsSinceEpoch}_${file.path.hashCode}';
    
    final int sizeBytes = file.existsSync() ? file.lengthSync() : 0;
    
    return MediaQueue(
      id: mediaId,
      syncQueueId: syncQueueId,
      filePath: file.path,
      totalSizeBytes: sizeBytes,
      state: MediaState.PENDING,
      fieldName: fieldName,
      arrayIndex: arrayIndex,
    );
  }
}
