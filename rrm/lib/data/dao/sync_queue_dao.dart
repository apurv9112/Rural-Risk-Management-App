import 'package:sqflite/sqflite.dart';
import '../models/sync_queue_model.dart';
import 'base_dao.dart';

class SyncQueueDao extends BaseDao {
  static const String tableName = 'sync_queue';

  Future<int> insert(SyncQueueModel queue) async {
    final database = await db;
    return await database.insert(
      tableName,
      queue.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SyncQueueModel?> getJobByUuid(String queueUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'queue_uuid = ?',
      whereArgs: [queueUuid],
    );
    if (maps.isNotEmpty) {
      return SyncQueueModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<SyncQueueModel>> getPendingJobs() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'status = ?',
      whereArgs: ['PENDING'],
      orderBy: 'created_at ASC',
    );
    return maps.map((e) => SyncQueueModel.fromMap(e)).toList();
  }

  Future<int> update(SyncQueueModel queue) async {
    final database = await db;
    return await database.update(
      tableName,
      queue.toMap(),
      where: 'queue_uuid = ?',
      whereArgs: [queue.queueUuid],
    );
  }

  Future<int> delete(String queueUuid) async {
    final database = await db;
    return await database.delete(
      tableName,
      where: 'queue_uuid = ?',
      whereArgs: [queueUuid],
    );
  }
}
