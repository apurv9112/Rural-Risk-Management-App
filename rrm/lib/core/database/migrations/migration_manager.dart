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
    // Add logic here for future schema upgrades
    // Example:
    // if (oldVersion < 2) { await _upgradeToV2(db); }
    // if (oldVersion < 3) { await _upgradeToV3(db); }
  }
}
