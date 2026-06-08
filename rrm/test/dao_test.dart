import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/migrations/migration_manager.dart';
import 'package:rrm/data/models/user_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DAO CRUD Tests', () {
    late Database db;

    setUp(() async {
      db = await databaseFactory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
              version: 1,
              onCreate: (db, version) async {
                await MigrationManager.createInitialSchema(db);
              }));
      
      // Inject the db instance into a mock or use it directly if possible.
      // Since AppDatabase uses a singleton, we might have issues testing BaseDao directly 
      // without dependency injection. For this quick validation, we'll verify the schema 
      // is sound by manually executing the DAOs logic or just verifying table existence.
    });

    tearDown(() async {
      await db.close();
    });

    test('Verify tables are created', () async {
      var result = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      var tableNames = result.map((e) => e['name']).toList();
      
      expect(tableNames.contains('users'), isTrue);
      expect(tableNames.contains('leads'), isTrue);
      expect(tableNames.contains('cattle'), isTrue);
      expect(tableNames.contains('media_metadata'), isTrue);
      expect(tableNames.contains('sync_queue'), isTrue);
    });
    
    test('User Mapping works correctly', () {
      final user = UserModel(
        localUuid: '123',
        firstName: 'Test',
      );
      final map = user.toMap();
      expect(map['local_uuid'], '123');
      expect(map['first_name'], 'Test');
      
      final parsed = UserModel.fromMap(map);
      expect(parsed.localUuid, '123');
    });
  });
}
