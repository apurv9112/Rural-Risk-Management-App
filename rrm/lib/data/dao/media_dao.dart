import 'package:sqflite/sqflite.dart';
import '../models/media_metadata_model.dart';
import 'base_dao.dart';

class MediaDao extends BaseDao {
  static const String tableName = 'media_metadata';

  Future<int> insert(MediaMetadataModel media) async {
    final database = await db;
    return await database.insert(
      tableName,
      media.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MediaMetadataModel?> getById(String localUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
    if (maps.isNotEmpty) {
      return MediaMetadataModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MediaMetadataModel>> getByCattleId(String cattleUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'cattle_uuid = ? AND deleted_at IS NULL',
      whereArgs: [cattleUuid],
    );
    return maps.map((e) => MediaMetadataModel.fromMap(e)).toList();
  }

  Future<List<MediaMetadataModel>> getArchivedMediaForCleanup(String dateThreshold) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'sync_status = ? AND created_at < ?',
      whereArgs: ['ARCHIVED', dateThreshold],
    );
    return maps.map((e) => MediaMetadataModel.fromMap(e)).toList();
  }

  Future<int> update(MediaMetadataModel media) async {
    final database = await db;
    return await database.update(
      tableName,
      media.toMap(),
      where: 'local_uuid = ?',
      whereArgs: [media.localUuid],
    );
  }

  Future<int> delete(String localUuid) async {
    final database = await db;
    return await database.delete(
      tableName,
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
  }
}
