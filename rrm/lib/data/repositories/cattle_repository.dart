import 'package:sqflite/sqflite.dart';
import '../models/cattle_model.dart';
import 'base_repository.dart';

class CattleRepository extends BaseRepository {
  static const String cattleTable = 'cattle';

  Future<void> saveDraftCattle(CattleModel cattle) async {
    final database = await db;
    await database.insert(
      cattleTable,
      cattle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDraftCattle(CattleModel cattle) async {
    final database = await db;
    await database.update(
      cattleTable,
      cattle.toMap(),
      where: 'local_uuid = ?',
      whereArgs: [cattle.localUuid],
    );
  }

  Future<List<CattleModel>> loadByLead(String leadUuid) async {
    final database = await db;
    final maps = await database.query(
      cattleTable,
      where: 'lead_uuid = ? AND deleted_at IS NULL',
      whereArgs: [leadUuid],
    );
    return maps.map((e) => CattleModel.fromMap(e)).toList();
  }

  Future<void> softDeleteCattle(String localUuid) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();

    await database.update(
      cattleTable,
      {'deleted_at': now},
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
  }
}
