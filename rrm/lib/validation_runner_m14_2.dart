import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/data/repositories/master_data_repository.dart';
import 'package:rrm/core/database/migrations/migration_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:rrm/core/master_data/master_data_seeder.dart';
import 'package:rrm/core/sync/master_data_sync_service.dart';
import 'package:rrm/data/models/master_data_sync_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=============================================');
  print('=== M14.2 SYNC ENGINE VALIDATION STARTING ===');
  print('=============================================');

  // Ensure fresh start for validation
  final dbPath = join(await getDatabasesPath(), 'rrm.db');
  await deleteDatabase(dbPath);

  // Initialize DB which triggers V6 migration
  final db = await AppDatabase.instance.database;
  final repo = MasterDataRepository();
  final syncService = MasterDataSyncService();

  print('\\n--- Phase 3 Validation - Cursor Framework ---');
  final tableInfo = await db.rawQuery("PRAGMA table_info('master_data_sync_state')");
  print('master_data_sync_state table exists: ${tableInfo.isNotEmpty}');

  print('\\n--- Phase 5 Validation - Seeder Compatibility ---');
  await MasterDataSeeder.seedIfNeeded();
  final seededBanks = await repo.getMasterData('banks');
  print('Seeded Banks count: ${seededBanks.length}');

  // Insert a mock SERVER row
  final mockItem = MasterDataSyncItem(
    serverId: 'bank-server-1',
    category: 'banks',
    key: 'BANK_SERVER',
    value: 'Server Bank',
    sortOrder: 1,
    version: 1,
    isActive: 1,
    serverUpdatedAt: DateTime.now().toIso8601String(),
  );
  await syncService.processSyncPayload('banks', [mockItem]);
  final afterServerSync = await repo.getMasterData('banks');
  print('Banks count after Sync Service: ${afterServerSync.length}');
  
  // Re-run seeder to verify it doesn't touch SERVER row
  await MasterDataSeeder.seedIfNeeded();
  final afterSecondSeed = await repo.getMasterData('banks');
  print('Banks count after second seeder run: ${afterSecondSeed.length}');

  print('\\n--- Phase 6 Validation - Mock API Simulation ---');
  // 1. Full Refresh (10 items)
  print('Testing Full Refresh (10 items)...');
  final fullRefresh = List.generate(10, (i) => MasterDataSyncItem(
    serverId: 'sim-val-$i',
    category: 'sim_data',
    key: 'SIM_$i',
    value: 'Sim Value $i',
    sortOrder: i,
    version: 1,
    isActive: 1,
    serverUpdatedAt: DateTime.now().toIso8601String(),
  ));
  await syncService.processSyncPayload('sim_data', fullRefresh);
  var simData = await repo.getMasterData('sim_data');
  print('Sim Data after refresh: ${simData.length}');
  
  // 2. Delta Update (modify 2 items, add 2 items)
  print('Testing Delta Update...');
  final deltaUpdate = [
    MasterDataSyncItem(
      serverId: 'sim-val-0',
      category: 'sim_data',
      key: 'SIM_0',
      value: 'Sim Value 0 UPDATED',
      sortOrder: 0,
      version: 2,
      isActive: 1,
      serverUpdatedAt: DateTime.now().toIso8601String(),
    ),
    MasterDataSyncItem(
      serverId: 'sim-val-new',
      category: 'sim_data',
      key: 'SIM_NEW',
      value: 'Sim Value NEW',
      sortOrder: 99,
      version: 1,
      isActive: 1,
      serverUpdatedAt: DateTime.now().toIso8601String(),
    ),
  ];
  await syncService.processSyncPayload('sim_data', deltaUpdate);
  simData = await repo.getMasterData('sim_data');
  print('Sim Data after delta: ${simData.length}');
  final updatedRow = simData.firstWhere((e) => e['server_id'] == 'sim-val-0');
  print('Updated row value: ${updatedRow['value']}');

  // 3. Soft Delete
  print('Testing Soft Delete...');
  final softDelete = [
    MasterDataSyncItem(
      serverId: 'sim-val-1',
      category: 'sim_data',
      key: 'SIM_1',
      value: 'Sim Value 1',
      sortOrder: 1,
      version: 3,
      isActive: 1,
      deletedAt: DateTime.now().toIso8601String(),
      serverUpdatedAt: DateTime.now().toIso8601String(),
    ),
  ];
  await syncService.processSyncPayload('sim_data', softDelete);
  simData = await repo.getMasterData('sim_data');
  print('Sim Data after soft delete: ${simData.length} (Expected 10 - 1 = 9? Actually 10+2-1 = 11 - wait 10+1-1 = 10)');
  final deletedRowPhysical = await db.query('master_data', where: 'server_id = ?', whereArgs: ['sim-val-1']);
  print('Deleted row exists physically: ${deletedRowPhysical.isNotEmpty}');
  print('Deleted row has deleted_at: ${deletedRowPhysical.first['deleted_at'] != null}');

  print('\\n--- Phase 7 Validation - Scale Performance (Moto g85 5G profile) ---');
  // Clean up
  await db.delete('master_data', where: 'category = ?', whereArgs: ['scale_test']);
  
  Future<void> runScaleTest(int count) async {
    print('Generating $count rows...');
    final payload = List.generate(count, (i) => MasterDataSyncItem(
      serverId: 'scale-$count-$i',
      category: 'scale_test',
      key: 'SCALE_$i',
      value: 'Scale $i',
      parentKey: 'TALUKA_${i % 1000}',
      sortOrder: i,
      version: 1,
      isActive: 1,
      serverUpdatedAt: DateTime.now().toIso8601String(),
    ));

    print('Starting Sync Service process for $count rows...');
    final start = DateTime.now();
    await syncService.processSyncPayload('scale_test', payload);
    final duration = DateTime.now().difference(start).inMilliseconds;
    print('Insert $count rows took: ${duration}ms');
    
    // Update exactly 10% of rows to test delta speed
    final updateCount = (count * 0.1).toInt();
    final updatePayload = List.generate(updateCount, (i) => MasterDataSyncItem(
      serverId: 'scale-$count-$i',
      category: 'scale_test',
      key: 'SCALE_$i',
      value: 'Scale $i UPDATED',
      parentKey: 'TALUKA_${i % 1000}',
      sortOrder: i,
      version: 2,
      isActive: 1,
      serverUpdatedAt: DateTime.now().toIso8601String(),
    ));
    final startUpd = DateTime.now();
    await syncService.processSyncPayload('scale_test', updatePayload);
    final durationUpd = DateTime.now().difference(startUpd).inMilliseconds;
    print('Update $updateCount rows (10% delta) took: ${durationUpd}ms');

    // Test lookup query time
    final startQ = DateTime.now();
    await repo.getMasterData('scale_test', parentKey: 'TALUKA_1');
    final qTime = DateTime.now().difference(startQ).inMilliseconds;
    print('Lookup query on $count rows took: ${qTime}ms');
    
    // Cleanup for next test
    await db.delete('master_data', where: 'category = ?', whereArgs: ['scale_test']);
  }

  await runScaleTest(1000);
  await runScaleTest(10000);
  await runScaleTest(100000);

  print('\\nCursor check:');
  final cursor = await syncService.getDeltaCursor('scale_test');
  print('Cursor exists: ${cursor != null}');

  print('\\n=============================================');
  print('=== M14.2 SYNC ENGINE VALIDATION COMPLETED ===');
  print('=============================================');
  exit(0);
}
