import 'package:sqflite/sqflite.dart';
import '../models/lead_model.dart';
import '../models/cattle_model.dart';
import 'base_repository.dart';

class LeadRepository extends BaseRepository {
  static const String leadsTable = 'leads';
  static const String cattleTable = 'cattle';

  /// Saves a Lead and its associated Cattle within a single transaction.
  /// If any insert fails, the transaction rolls back entirely.
  Future<void> saveDraftLead(LeadModel lead, List<CattleModel> cattleList) async {
    final database = await db;
    await database.transaction((txn) async {
      // 1. Insert Lead
      await txn.insert(
        leadsTable,
        lead.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Insert all Cattle associated with this lead
      for (final cattle in cattleList) {
        await txn.insert(
          cattleTable,
          cattle.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Updates an existing Draft Lead (strictly UPDATE, not INSERT)
  Future<void> updateDraftLead(LeadModel lead) async {
    final database = await db;
    await database.update(
      leadsTable,
      lead.toMap(),
      where: 'local_uuid = ?',
      whereArgs: [lead.localUuid],
    );
  }

  /// Loads a Draft Lead and its child cattle
  Future<Map<String, dynamic>?> loadDraftLead(String localUuid) async {
    final database = await db;
    
    final leadMaps = await database.query(
      leadsTable,
      where: 'local_uuid = ? AND deleted_at IS NULL',
      whereArgs: [localUuid],
    );

    if (leadMaps.isEmpty) return null;

    final cattleMaps = await database.query(
      cattleTable,
      where: 'lead_uuid = ? AND deleted_at IS NULL',
      whereArgs: [localUuid],
    );

    return {
      'lead': LeadModel.fromMap(leadMaps.first),
      'cattle': cattleMaps.map((e) => CattleModel.fromMap(e)).toList(),
    };
  }

  /// Loads all active leads in DRAFT status
  Future<List<LeadModel>> loadActiveDrafts() async {
    final database = await db;
    final leadMaps = await database.query(
      leadsTable,
      where: "sync_status = 'DRAFT' AND deleted_at IS NULL",
    );
    return leadMaps.map((e) => LeadModel.fromMap(e)).toList();
  }


  /// Soft deletes a lead and its cattle
  Future<void> softDeleteLead(String localUuid) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();

    await database.transaction((txn) async {
      await txn.update(
        leadsTable,
        {'deleted_at': now},
        where: 'local_uuid = ?',
        whereArgs: [localUuid],
      );

      await txn.update(
        cattleTable,
        {'deleted_at': now},
        where: 'lead_uuid = ?',
        whereArgs: [localUuid],
      );
    });
  }
}
