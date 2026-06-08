import 'package:sqflite/sqflite.dart';
import '../models/sync_log_model.dart';
import 'base_dao.dart';

class SyncLogsDao extends BaseDao {
  static const String tableName = 'sync_logs';

  Future<int> insert(SyncLogModel log) async {
    final database = await db;
    return await database.insert(
      tableName,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SyncLogModel?> getById(String logUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'log_uuid = ?',
      whereArgs: [logUuid],
    );
    if (maps.isNotEmpty) {
      return SyncLogModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(SyncLogModel log) async {
    final database = await db;
    return await database.update(
      tableName,
      log.toMap(),
      where: 'log_uuid = ?',
      whereArgs: [log.logUuid],
    );
  }

  Future<int> delete(String logUuid) async {
    final database = await db;
    return await database.delete(
      tableName,
      where: 'log_uuid = ?',
      whereArgs: [logUuid],
    );
  }
}
