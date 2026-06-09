import 'package:sqflite/sqflite.dart';
import '../schema/v1_initial_schema.dart';

class MigrationManager {
  static Future<void> createInitialSchema(Database db) async {
    for (final tableSql in V1InitialSchema.createTables) {
      await db.execute(tableSql);
    }
    for (final indexSql in V1InitialSchema.createIndexes) {
      await db.execute(indexSql);
    }
  }

  static Future<void> performUpgrades(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _upgradeToV2(db);
    }
  }

  static Future<void> _upgradeToV2(Database db) async {
    await db.execute('''
    CREATE TABLE draft_progress (
      entity_uuid TEXT PRIMARY KEY,
      workflow_type TEXT,
      current_step INTEGER,
      last_screen_route TEXT,
      completion_percentage REAL,
      updated_at TEXT
    )
    ''');
  }
}
