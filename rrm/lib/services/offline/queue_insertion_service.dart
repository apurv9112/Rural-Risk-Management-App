import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';

class MediaQueueItem {
  final String mediaUuid;
  final String localFilePath;
  final String fileName;
  final String mimeType;
  final int fileSizeBytes;
  final String checksum;
  final String mediaKeyName;

  MediaQueueItem({
    required this.mediaUuid,
    required this.localFilePath,
    required this.fileName,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.checksum,
    required this.mediaKeyName,
  });
}

class QueueInsertionService {
  final Database? db;

  QueueInsertionService({this.db});

  Future<Database> get _db async => db ?? await AppDatabase.instance.database;

  Future<String> enqueueSubmission({
    required String operationType,
    required String entityType,
    required Map<String, dynamic> metadata,
    required List<MediaQueueItem> mediaItems,
    String dependencyQueueUuid = '',
    String? entityUuid,
  }) async {
    final database = await _db;
    final uuid = const Uuid();
    final queueUuid = uuid.v4();

    await database.transaction((txn) async {
      // 1. Create Parent sync_queue row
      final hasMedia = mediaItems.isNotEmpty;
      final payloadJson = jsonEncode(metadata);

      await txn.insert('sync_queue', {
        'queue_uuid': queueUuid,
        'dependency_queue_uuid': dependencyQueueUuid.isEmpty ? null : dependencyQueueUuid,
        'entity_type': entityType,
        'entity_uuid': entityUuid,
        'operation_type': operationType,
        'payload_json': payloadJson,
        'status': hasMedia ? 'BLOCKED_BY_MEDIA' : 'PENDING',
        'media_status': hasMedia ? 'PENDING' : 'COMPLETED',
        'idempotency_key': 'idem_$queueUuid',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Create Child media_queue rows
      for (int i = 0; i < mediaItems.length; i++) {
        final item = mediaItems[i];
        await txn.insert('media_queue', {
          'media_uuid': item.mediaUuid,
          'queue_uuid': queueUuid,
          'workflow_type': entityType,
          'priority': mediaItems.length - i, // First items have higher priority
          'local_file_path': item.localFilePath,
          'file_name': item.fileName,
          'mime_type': item.mimeType,
          'file_size': item.fileSizeBytes,
          'checksum': item.checksum,
          'media_key_name': item.mediaKeyName,
          'upload_status': 'PENDING',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });

    return queueUuid;
  }
}
