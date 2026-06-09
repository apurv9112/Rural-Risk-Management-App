import 'package:flutter/material.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/data/repositories/master_data_repository.dart';
import 'package:rrm/core/master_data/master_data_sync_coordinator.dart';
import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

// Mock Client that throws on specific pages
class MockClient implements MasterDataSyncClient {
  int failOnPage = -1;
  int delayMs = 100;
  
  @override
  Future<Map<String, dynamic>> fetchPage(String category, int page, int pageSize) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    if (page == failOnPage) {
      throw Exception('Simulated Network Timeout on Page $page');
    }
    
    return {
      'total_pages': 5,
      'last_server_updated_at': DateTime.now().toIso8601String(),
      'items': List.generate(pageSize, (index) => {
        'server_id': 'srv_${page}_$index',
        'key': 'key_${page}_$index',
        'value': 'Value $page $index',
        'is_active': 1,
        'version': 1,
        'server_updated_at': DateTime.now().toIso8601String(),
      }),
    };
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Wipe database before test to ensure clean migration state
  final dbPath = await getDatabasesPath();
  await deleteDatabase('$dbPath/rrm.db');
  
  final db = await AppDatabase.instance.database;
  final repo = MasterDataRepository();
  final client = MockClient();
  final coordinator = MasterDataSyncCoordinator(repo, client);

  print('=============================================');
  print('=== M14.7 COORDINATOR VALIDATION RUNNER ===');
  print('=============================================');

  // Scenario A: Simulate mid-page crash
  print('\\n--- Scenario A: Simulate Network Crash Mid-Sync (Page 3) ---');
  client.failOnPage = 3;
  await coordinator.syncCategory('test_cat');
  
  var state = await repo.getSyncState('test_cat');
  print('State after crash: Status=${state?['sync_status']}, CurrentPage=${state?['current_page']}');
  
  var count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM master_data WHERE category="test_cat"'));
  print('Row count after crash: $count (Expected: 200)');

  // Scenario B: Resume from crash
  print('\\n--- Scenario B: Resume from Crash ---');
  client.failOnPage = -1; // No more failures
  await coordinator.syncCategory('test_cat');
  
  state = await repo.getSyncState('test_cat');
  print('State after resume: Status=${state?['sync_status']}, CurrentPage=${state?['current_page']}');
  count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM master_data WHERE category="test_cat"'));
  print('Row count after resume: $count (Expected: 500)');

  // Scenario C: Concurrent Protection
  print('\\n--- Scenario C: Concurrent Trigger Protection ---');
  // Trigger two syncs almost simultaneously
  final future1 = coordinator.syncCategory('test_cat_2');
  final future2 = coordinator.syncCategory('test_cat_2');
  
  await Future.wait([future1, future2]);
  count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM master_data WHERE category="test_cat_2"'));
  print('Row count after concurrent trigger: $count (Expected: 500)');

  // Scenario D: Stale IN_PROGRESS Recovery (>15 min)
  print('\\n--- Scenario D: Stale Lock Recovery ---');
  // Manually force a stale lock
  await db.insert('master_data_sync_state', {
    'category': 'stale_cat',
    'sync_session_id': 'stale_session',
    'current_page': 4,
    'total_pages': 5,
    'sync_status': 'IN_PROGRESS',
    'updated_at': DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.replace);
  
  // Coordinator should recognize > 15 mins age and resume from page 4
  await coordinator.syncCategory('stale_cat');
  
  state = await repo.getSyncState('stale_cat');
  print('State after stale resume: Status=${state?['sync_status']}, CurrentPage=${state?['current_page']}');
  count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM master_data WHERE category="stale_cat"'));
  // Page 4 and 5 were fetched -> 200 items. (We didn't fetch 1-3 since we forced state to page 4)
  print('Row count after stale resume: $count (Expected: 200)');

  print('\\n=============================================');
  print('=== M14.7 VALIDATION RUN COMPLETED ===');
  print('=============================================');
  
  await AppDatabase.instance.close();
  // We use exit to gracefully stop the hot-reload runner process
  exit(0);
}
