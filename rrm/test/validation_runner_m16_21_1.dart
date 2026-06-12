import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'package:rrm/services/offline/queue_models.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/rrm_sync.db';
    if (File(path).existsSync()) {
      await databaseFactory.deleteDatabase(path);
    }
  });

  test('M16.21.1: Database Foundation Validation', () async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/rrm_sync.db';
    
    // Make sure we start clean
    if (File(path).existsSync()) {
      await databaseFactory.deleteDatabase(path);
    }
    
    final appDb = AppDatabase.instance;
    final db = await appDb.database;
    
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);

    print('\n--- A. Schema Creation ---');
    final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
    final tableNames = tables.map((t) => t['name'] as String).toList();
    expect(tableNames.contains('sync_queue'), isTrue, reason: 'sync_queue table should exist');
    expect(tableNames.contains('media_queue'), isTrue, reason: 'media_queue table should exist');
    print('SUCCESS: Tables created properly.');

    print('\n--- B. Foreign Key Enforcement ---');
    bool fkEnforced = false;
    try {
      await mediaRepo.insert(MediaQueue(
        id: 'media_no_parent',
        syncQueueId: 'non_existent_sync',
        filePath: 'test.jpg',
        totalSizeBytes: 100,
      ));
    } catch (e) {
      fkEnforced = true;
    }
    expect(fkEnforced, isTrue, reason: 'Foreign key constraint should prevent insert without parent');
    print('SUCCESS: Foreign key prevented orphaned media insertion.');

    print('\n--- C. Cascade Delete ---');
    final parentSync = SyncQueue(id: 'sync_parent');
    await syncRepo.insert(parentSync);
    await mediaRepo.insert(MediaQueue(
      id: 'media_child',
      syncQueueId: 'sync_parent',
      filePath: 'test.jpg',
      totalSizeBytes: 100,
      fieldName: 'files',
    ));
    
    final mediaBefore = await mediaRepo.getBySyncQueueId('sync_parent');
    expect(mediaBefore.length, 1);
    
    await syncRepo.delete('sync_parent');
    
    final mediaAfter = await mediaRepo.getBySyncQueueId('sync_parent');
    expect(mediaAfter.isEmpty, isTrue, reason: 'Media should be deleted when parent sync is deleted');
    print('SUCCESS: Cascade delete works.');

    print('\n--- D. 10,000 Row Insert ---');
    final stopwatch = Stopwatch()..start();
    await db.transaction((txn) async {
      for (int i = 0; i < 1000; i++) {
        final sqId = 'bulk_sync_$i';
        await txn.insert('sync_queue', {
          'id': sqId,
          'state': SyncState.COMPLETED.name,
          'payload': '{}',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
        
        for (int j = 0; j < 10; j++) {
          await txn.insert('media_queue', {
            'id': 'bulk_media_${i}_$j',
            'syncQueueId': sqId,
            'filePath': 'bulk.jpg',
            'totalSizeBytes': 100,
            'uploadedBytes': 100,
            'state': MediaState.COMPLETED.name,
            'fieldName': 'files',
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }
    });
    stopwatch.stop();
    print('SUCCESS: Inserted 1000 SyncQueues and 10000 MediaQueues in ${stopwatch.elapsedMilliseconds} ms.');
    expect(stopwatch.elapsedMilliseconds, lessThan(5000), reason: 'Insertions should be fast inside a transaction');

    print('\n--- E. Indexed Lookup Performance ---');
    final lookupTimer = Stopwatch()..start();
    final childMedia = await mediaRepo.getBySyncQueueId('bulk_sync_500');
    lookupTimer.stop();
    expect(childMedia.length, 10);
    print('SUCCESS: Indexed lookup took ${lookupTimer.elapsedMilliseconds} ms.');
    expect(lookupTimer.elapsedMilliseconds, lessThan(50), reason: 'Lookup should be almost instant with index');

    print('\n--- F. App Restart Persistence Simulation ---');
    await appDb.close(); // Close DB connection
    
    // Re-open via AppDatabase
    final db2 = await AppDatabase.instance.database;
    final rowCount = Sqflite.firstIntValue(await db2.rawQuery('SELECT COUNT(*) FROM media_queue'));
    expect(rowCount, 10000);
    print('SUCCESS: Data persists across connection close/open. Found $rowCount media queues.');
    
    await AppDatabase.instance.close();
  });
}
