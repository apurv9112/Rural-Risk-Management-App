import 'package:sqflite/sqflite.dart';
import 'package:rrm/services/offline/queue_models.dart';
import '../app_database.dart';

class MediaQueueRepository {
  final AppDatabase _appDatabase;

  MediaQueueRepository(this._appDatabase);

  Future<Database> get db => _appDatabase.database;

  Future<void> insert(MediaQueue media) async {
    final database = await db;
    await database.insert(
      'media_queue',
      _toMap(media),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(MediaQueue media) async {
    final database = await db;
    await database.update(
      'media_queue',
      _toMap(media),
      where: 'id = ?',
      whereArgs: [media.id],
    );
  }

  Future<void> delete(String id) async {
    final database = await db;
    await database.delete(
      'media_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<MediaQueue?> getById(String id) async {
    final database = await db;
    final maps = await database.query(
      'media_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _fromMap(maps.first);
    }
    return null;
  }

  Future<List<MediaQueue>> getBySyncQueueId(String syncQueueId) async {
    final database = await db;
    final maps = await database.query(
      'media_queue',
      where: 'syncQueueId = ?',
      whereArgs: [syncQueueId],
    );
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<List<MediaQueue>> getAll() async {
    final database = await db;
    final maps = await database.query('media_queue');
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<List<MediaQueue>> getByStates(List<MediaState> states) async {
    if (states.isEmpty) return [];
    final database = await db;
    final stateNames = states.map((s) => s.name).toList();
    final placeholders = List.filled(states.length, '?').join(',');
    final maps = await database.query(
      'media_queue',
      where: 'state IN ($placeholders)',
      whereArgs: stateNames,
    );
    return maps.map((map) => _fromMap(map)).toList();
  }

  Map<String, dynamic> _toMap(MediaQueue media) {
    return {
      'id': media.id,
      'syncQueueId': media.syncQueueId,
      'filePath': media.filePath,
      'totalSizeBytes': media.totalSizeBytes,
      'uploadedBytes': media.uploadedBytes,
      'state': media.state.name,
      'fieldName': media.fieldName,
      'arrayIndex': media.arrayIndex,
      'remoteAssetId': media.remoteAssetId,
      'remoteUploadId': media.remoteUploadId,
      'checksum': media.checksum,
      'createdAt': media.createdAt.millisecondsSinceEpoch,
      'updatedAt': media.updatedAt.millisecondsSinceEpoch,
    };
  }

  MediaQueue _fromMap(Map<String, dynamic> map) {
    return MediaQueue(
      id: map['id'] as String,
      syncQueueId: map['syncQueueId'] as String,
      filePath: map['filePath'] as String,
      totalSizeBytes: map['totalSizeBytes'] as int,
      uploadedBytes: map['uploadedBytes'] as int,
      state: MediaState.values.firstWhere((e) => e.name == map['state']),
      fieldName: map['fieldName'] as String,
      arrayIndex: map['arrayIndex'] as int?,
      remoteAssetId: map['remoteAssetId'] as String?,
      remoteUploadId: map['remoteUploadId'] as String?,
      checksum: map['checksum'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }
}
