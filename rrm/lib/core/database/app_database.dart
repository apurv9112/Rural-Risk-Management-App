
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'migration_manager.dart';
import 'migrations/v1_initial_schema.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rrm_sync.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: V1InitialSchema.version,
      onCreate: MigrationManager.onCreate,
      onUpgrade: MigrationManager.onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}
