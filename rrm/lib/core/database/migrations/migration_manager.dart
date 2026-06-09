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
    if (oldVersion < 3) {
      await _upgradeToV3(db);
    }
    if (oldVersion < 4) {
      await _upgradeToV4(db);
    }
    if (oldVersion < 5) {
      await _upgradeToV5(db);
    }
    if (oldVersion < 6) {
      await _upgradeToV6(db);
    }
    if (oldVersion < 7) {
      await _upgradeToV7(db);
    }
    if (oldVersion < 8) {
      await _upgradeToV8(db);
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

  static Future<void> _upgradeToV3(Database db) async {
    try { await db.execute('ALTER TABLE master_data ADD COLUMN server_id TEXT'); } catch (_) {}
    try { await db.execute('ALTER TABLE master_data ADD COLUMN sync_source TEXT DEFAULT "SEED"'); } catch (_) {}
    try { await db.execute('ALTER TABLE master_data ADD COLUMN version INTEGER DEFAULT 1'); } catch (_) {}
    try { await db.execute('ALTER TABLE master_data ADD COLUMN deleted_at TEXT'); } catch (_) {}
    try { await db.execute('ALTER TABLE master_data ADD COLUMN updated_at TEXT'); } catch (_) {}
    try { await db.execute('ALTER TABLE master_data ADD COLUMN sort_order INTEGER DEFAULT 0'); } catch (_) {}
  }

  static Future<void> _upgradeToV4(Database db) async {
    try { await db.execute('CREATE INDEX IF NOT EXISTS idx_queue_sort ON sync_queue(status, created_at);'); } catch (_) {}
  }

  static Future<void> _upgradeToV5(Database db) async {
    try { await db.execute('CREATE INDEX IF NOT EXISTS idx_master_data_lookup ON master_data(category, parent_key, is_active, deleted_at);'); } catch (_) {}
    try { await db.execute('CREATE INDEX IF NOT EXISTS idx_master_data_server ON master_data(server_id);'); } catch (_) {}
    try { await db.execute('CREATE INDEX IF NOT EXISTS idx_master_data_updated ON master_data(server_updated_at);'); } catch (_) {}
  }

  static Future<void> _upgradeToV6(Database db) async {
    try {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS master_data_sync_state (
        category TEXT PRIMARY KEY,
        last_server_updated_at TEXT,
        last_sync_at TEXT
      )
      ''');
    } catch (_) {}
  }

  static Future<void> _upgradeToV7(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS master_data_sync_state');
      await db.execute('''
      CREATE TABLE master_data_sync_state (
          category TEXT PRIMARY KEY,
          sync_session_id TEXT,
          last_server_updated_at TEXT,
          current_page INTEGER DEFAULT 1,
          total_pages INTEGER DEFAULT 1,
          sync_status TEXT,
          last_successful_sync_at TEXT,
          last_error TEXT,
          started_at TEXT,
          completed_at TEXT,
          updated_at TEXT
      )
      ''');
    } catch (_) {}
  }

  static Future<void> _upgradeToV8(Database db) async {
    try {
      await db.execute('ALTER TABLE sync_queue ADD COLUMN media_status TEXT DEFAULT "COMPLETED"');
    } catch (_) {}

    try {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS media_queue (
          media_uuid TEXT PRIMARY KEY,
          queue_uuid TEXT NOT NULL,
          workflow_type TEXT,
          priority INTEGER DEFAULT 0,
          local_file_path TEXT NOT NULL,
          file_name TEXT NOT NULL,
          mime_type TEXT,
          file_size INTEGER NOT NULL,
          checksum TEXT,
          media_key_name TEXT NOT NULL,
          remote_asset_id TEXT,
          remote_upload_id TEXT,
          uploaded_bytes INTEGER DEFAULT 0,
          upload_status TEXT DEFAULT 'PENDING',
          upload_attempts INTEGER DEFAULT 0,
          last_error TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY(queue_uuid) REFERENCES sync_queue(queue_uuid) ON DELETE CASCADE
      )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_media_queue_uuid ON media_queue(queue_uuid);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_media_upload_status ON media_queue(upload_status);');
    } catch (_) {}
  }
}
