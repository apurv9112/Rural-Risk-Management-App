import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';

class MediaQueueRepository {
  final Database? db;

  MediaQueueRepository({this.db});

  Future<Database> get _db async => db ?? await AppDatabase.instance.database;

  Future<void> createMedia(Map<String, dynamic> media) async {
    final database = await _db;
    await database.insert(
      'media_queue',
      media,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateMediaMetadata(String mediaUuid, Map<String, dynamic> updates) async {
    final database = await _db;
    
    // Ensure we don't accidentally overwrite progress fields via metadata updates
    final safeUpdates = Map<String, dynamic>.from(updates)
      ..remove('remote_upload_id')
      ..remove('remote_asset_id')
      ..remove('uploaded_bytes')
      ..remove('upload_status')
      ..remove('upload_attempts')
      ..remove('last_error');
      
    if (safeUpdates.isEmpty) return;
    
    safeUpdates['updated_at'] = DateTime.now().toIso8601String();

    await database.update(
      'media_queue',
      safeUpdates,
      where: 'media_uuid = ?',
      whereArgs: [mediaUuid],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingMedia() async {
    final database = await _db;
    return await database.query(
      'media_queue',
      where: 'upload_status IN (?, ?)',
      whereArgs: ['PENDING', 'RETRY_PENDING'],
      orderBy: 'priority DESC, created_at ASC',
    );
  }

  Future<Map<String, dynamic>?> getNextPendingMedia() async {
    final database = await _db;
    final results = await database.query(
      'media_queue',
      where: 'upload_status IN (?, ?)',
      whereArgs: ['PENDING', 'RETRY_PENDING'],
      orderBy: 'priority DESC, created_at ASC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> countIncompleteMediaForQueue(String queueUuid) async {
    final database = await _db;
    final results = await database.rawQuery(
      'SELECT COUNT(*) as count FROM media_queue WHERE queue_uuid = ? AND upload_status != ?',
      [queueUuid, 'COMPLETED'],
    );
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> recoverStaleLocks(int olderThanMinutes) async {
    final database = await _db;
    final threshold = DateTime.now().subtract(Duration(minutes: olderThanMinutes)).toIso8601String();
    return await database.update(
      'media_queue',
      {
        'upload_status': 'RETRY_PENDING',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'upload_status = ? AND updated_at < ?',
      whereArgs: ['UPLOADING', threshold],
    );
  }

  Future<bool> claimMediaForUpload(String mediaUuid) async {
    final database = await _db;
    final changes = await database.update(
      'media_queue',
      {'upload_status': 'UPLOADING', 'updated_at': DateTime.now().toIso8601String()},
      where: 'media_uuid = ? AND upload_status IN (?, ?)',
      whereArgs: [mediaUuid, 'PENDING', 'RETRY_PENDING'],
    );
    return changes > 0;
  }

  Future<void> updateUploadProgress(String mediaUuid, String uploadId, int bytes) async {
    final database = await _db;
    await database.update(
      'media_queue',
      {
        'remote_upload_id': uploadId,
        'uploaded_bytes': bytes,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'media_uuid = ?',
      whereArgs: [mediaUuid],
    );
  }

  Future<void> markCompleted(String mediaUuid, String assetId) async {
    final database = await _db;
    await database.update(
      'media_queue',
      {
        'upload_status': 'COMPLETED',
        'remote_asset_id': assetId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'media_uuid = ?',
      whereArgs: [mediaUuid],
    );
  }

  Future<void> markFailed(String mediaUuid, String error, {bool isTerminal = false}) async {
    final database = await _db;
    
    // We fetch the attempts to increment
    final rows = await database.query(
      'media_queue',
      columns: ['upload_attempts'],
      where: 'media_uuid = ?',
      whereArgs: [mediaUuid],
      limit: 1,
    );
    
    int attempts = 0;
    if (rows.isNotEmpty) {
      attempts = (rows.first['upload_attempts'] as int?) ?? 0;
    }
    
    await database.update(
      'media_queue',
      {
        'upload_status': (isTerminal || attempts >= 5) ? 'FAILED' : 'RETRY_PENDING',
        'upload_attempts': attempts + 1,
        'last_error': error,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'media_uuid = ?',
      whereArgs: [mediaUuid],
    );
  }
}
