import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations/migration_manager.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rrm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.rawQuery('PRAGMA journal_mode = WAL');
  }

  Future<void> _createDB(Database db, int version) async {
    await MigrationManager.createInitialSchema(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await MigrationManager.performUpgrades(db, oldVersion, newVersion);
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
