import 'package:sqflite/sqflite.dart';
import '../models/lead_model.dart';
import 'base_dao.dart';

class LeadsDao extends BaseDao {
  static const String tableName = 'leads';

  Future<int> insert(LeadModel lead) async {
    final database = await db;
    return await database.insert(
      tableName,
      lead.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<LeadModel?> getById(String localUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
    if (maps.isNotEmpty) {
      return LeadModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<LeadModel>> getPendingSyncLeads() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'sync_status = ? AND deleted_at IS NULL',
      whereArgs: ['PENDING'],
    );
    return maps.map((e) => LeadModel.fromMap(e)).toList();
  }

  Future<int> update(LeadModel lead) async {
    final database = await db;
    return await database.update(
      tableName,
      lead.toMap(),
      where: 'local_uuid = ?',
      whereArgs: [lead.localUuid],
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
