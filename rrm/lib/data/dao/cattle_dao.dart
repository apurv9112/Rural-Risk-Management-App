import 'package:sqflite/sqflite.dart';
import '../models/cattle_model.dart';
import 'base_dao.dart';

class CattleDao extends BaseDao {
  static const String tableName = 'cattle';

  Future<int> insert(CattleModel cattle) async {
    final database = await db;
    return await database.insert(
      tableName,
      cattle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CattleModel?> getById(String localUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
    if (maps.isNotEmpty) {
      return CattleModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<CattleModel>> getByLeadId(String leadUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'lead_uuid = ? AND deleted_at IS NULL',
      whereArgs: [leadUuid],
    );
    return maps.map((e) => CattleModel.fromMap(e)).toList();
  }

  Future<int> update(CattleModel cattle) async {
    final database = await db;
    return await database.update(
      tableName,
      cattle.toMap(),
      where: 'local_uuid = ?',
      whereArgs: [cattle.localUuid],
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
