import 'package:sqflite/sqflite.dart';
import 'migrations/v1_initial_schema.dart';

class MigrationManager {
  static Future<void> onCreate(Database db, int version) async {
    // Version 1 setup
    await db.execute(V1InitialSchema.createSyncQueueTable);
    await db.execute(V1InitialSchema.createMediaQueueTable);
    
    // Create indexes
    await db.execute(V1InitialSchema.idxSyncState);
    await db.execute(V1InitialSchema.idxMediaSyncId);
    await db.execute(V1InitialSchema.idxMediaState);
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
  }
}
