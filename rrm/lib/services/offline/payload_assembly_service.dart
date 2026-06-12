import 'queue_models.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';

class PayloadAssemblyException implements Exception {
  final String message;
  PayloadAssemblyException(this.message);

  @override
  String toString() => 'PayloadAssemblyException: $message';
}

class PayloadAssemblyService {
  final SyncQueueRepository syncQueueRepository;
  final MediaQueueRepository mediaQueueRepository;

  PayloadAssemblyService({
    required this.syncQueueRepository,
    required this.mediaQueueRepository,
  });

  Future<Map<String, dynamic>> assemblePayload(String syncQueueId) async {
    final syncQueue = await syncQueueRepository.getById(syncQueueId);
    if (syncQueue == null) {
      throw PayloadAssemblyException('SyncQueue $syncQueueId not found');
    }

    final mediaItems = await mediaQueueRepository.getBySyncQueueId(syncQueueId);

    // 1. Verify all media rows are COMPLETED and have remote_asset_id
    for (final media in mediaItems) {
      if (media.state != MediaState.COMPLETED) {
        throw PayloadAssemblyException('Media item ${media.id} is not COMPLETED (state: ${media.state})');
      }
      if (media.remoteAssetId == null) {
        throw PayloadAssemblyException('Media item ${media.id} is missing remote_asset_id');
      }
    }

    // 2. Clone the initial payload to avoid mutating original source if it fails midway
    Map<String, dynamic> assembledPayload = Map<String, dynamic>.from(syncQueue.payload);

    // 3. Extract Single Assets & Group Array Assets
    final Map<String, List<MediaQueue>> arrayMap = {};
    
    for (final media in mediaItems) {
      if (media.fieldName == null) {
        continue;
      }
      
      final fieldName = media.fieldName!;
      
      if (fieldName == 'files' || fieldName == 'cancellationImages') {
        // Array fields
        arrayMap.putIfAbsent(fieldName, () => []).add(media);
      } else {
        // Single fields
        final targetKey = '${fieldName}AssetId';
        if (assembledPayload.containsKey(targetKey)) {
          throw PayloadAssemblyException('Duplicate single asset for field: $fieldName');
        }
        assembledPayload[targetKey] = media.remoteAssetId;
      }
    }

    // 4. Assemble Arrays (Sort by arrayIndex ASC)
    for (final entry in arrayMap.entries) {
      final fieldName = entry.key;
      final items = entry.value;

      // Ensure all array items have arrayIndex
      if (items.any((m) => m.arrayIndex == null)) {
        throw PayloadAssemblyException('Array item for $fieldName is missing arrayIndex');
      }

      // Sort strictly by arrayIndex
      items.sort((a, b) => a.arrayIndex!.compareTo(b.arrayIndex!));

      // Validate duplicate array indices
      for (int i = 0; i < items.length - 1; i++) {
        if (items[i].arrayIndex == items[i + 1].arrayIndex) {
          throw PayloadAssemblyException('Duplicate array index ${items[i].arrayIndex} for field: $fieldName');
        }
      }

      final targetKey = fieldName == 'files' ? 'filesAssetIds' : '${fieldName}AssetIds';
      assembledPayload[targetKey] = items.map((m) => m.remoteAssetId!).toList();
    }

    return assembledPayload;
  }
}
