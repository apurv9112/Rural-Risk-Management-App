import 'package:sqflite/sqflite.dart';
import '../models/conflict_log_model.dart';
import 'base_dao.dart';

class ConflictLogDao extends BaseDao {
  static const String tableName = 'conflict_log';

  Future<int> insert(ConflictLogModel conflict) async {
    final database = await db;
    return await database.insert(
      tableName,
      conflict.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ConflictLogModel?> getById(String conflictUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'conflict_uuid = ?',
      whereArgs: [conflictUuid],
    );
    if (maps.isNotEmpty) {
      return ConflictLogModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(ConflictLogModel conflict) async {
    final database = await db;
    return await database.update(
      tableName,
      conflict.toMap(),
      where: 'conflict_uuid = ?',
      whereArgs: [conflict.conflictUuid],
    );
  }

  Future<int> delete(String conflictUuid) async {
    final database = await db;
    return await database.delete(
      tableName,
      where: 'conflict_uuid = ?',
      whereArgs: [conflictUuid],
    );
  }
}
