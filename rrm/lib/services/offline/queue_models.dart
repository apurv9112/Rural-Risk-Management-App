// ignore_for_file: constant_identifier_names
import 'dart:async';

// ignore_constant_identifier_names
enum MediaState {
  PENDING,
  UPLOADING,
  INIT,
  CHUNK_LOOP,
  COMPLETE,
  COMPLETED,
  RETRY_PENDING,
  FAILED,
}

class MediaQueue {
  String id;
  String syncQueueId;
  String filePath;
  int totalSizeBytes;
  int uploadedBytes;
  String? remoteUploadId;
  String? remoteAssetId;
  MediaState state;
  String? fieldName;
  int? arrayIndex;
  String? checksum;
  DateTime createdAt;
  DateTime updatedAt;

  MediaQueue({
    required this.id,
    required this.syncQueueId,
    required this.filePath,
    required this.totalSizeBytes,
    this.uploadedBytes = 0,
    this.remoteUploadId,
    this.remoteAssetId,
    this.state = MediaState.PENDING,
    this.fieldName,
    this.arrayIndex,
    this.checksum,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}

// ignore_constant_identifier_names
enum SyncState {
  PENDING,
  UPLOADING_MEDIA,
  ELIGIBLE_FOR_SYNC,
  COMPLETED,
  FAILED,
}

class SyncQueue {
  String id;
  SyncState state;
  Map<String, dynamic> payload;
  DateTime createdAt;
  DateTime updatedAt;

  SyncQueue({
    required this.id,
    this.state = SyncState.PENDING,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : payload = payload ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}

class MockDatabase {
  final Map<String, SyncQueue> syncQueues = {};
  final Map<String, MediaQueue> mediaQueues = {};
  
  final _changeController = StreamController<void>.broadcast();
  Stream<void> get onChange => _changeController.stream;
  
  void _notify() {
    if (!_changeController.isClosed) {
      _changeController.add(null);
    }
  }

  void insertSyncQueue(SyncQueue queue) {
    syncQueues[queue.id] = queue;
    _notify();
  }

  void insertMediaQueue(MediaQueue media) {
    mediaQueues[media.id] = media;
    _notify();
  }

  void updateMediaQueue(MediaQueue media) {
    mediaQueues[media.id] = media;
    _notify();
  }

  void updateSyncQueue(SyncQueue queue) {
    syncQueues[queue.id] = queue;
    _notify();
  }

  List<MediaQueue> getMediaForSync(String syncId) {
    return mediaQueues.values.where((m) => m.syncQueueId == syncId).toList();
  }

  int countIncompleteMediaForQueue(String syncId) {
    return mediaQueues.values
        .where((m) => m.syncQueueId == syncId && m.state != MediaState.COMPLETED)
        .length;
  }
}
