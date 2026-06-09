import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/data/repositories/master_data_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:rrm/core/sync/master_data_sync_service.dart';
import 'package:rrm/data/models/master_data_sync_item.dart';
import 'package:rrm/core/master_data/master_data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=============================================');
  print('=== M14.4 VERSION PROTECTION VALIDATION ===');
  print('=============================================');

  final dbPath = join(await getDatabasesPath(), 'rrm.db');
  await deleteDatabase(dbPath);

  final db = await AppDatabase.instance.database;
  final repo = MasterDataRepository();
  final syncService = MasterDataSyncService();

  Future<int> getRowCount(String category) async {
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM master_data WHERE category = ?', [category]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  print('\\n--- Phase 4: Batch Processing Validation (10,000 rows) ---');
  final start4 = DateTime.now();
  final payload4 = List.generate(10000, (i) => MasterDataSyncItem(
    serverId: 'batch-val-$i', category: 'batch_test', key: 'B_$i', value: 'Val $i',
    sortOrder: i, version: 1, isActive: 1, serverUpdatedAt: DateTime.now().toIso8601String(),
  ));
  await syncService.processSyncPayload('batch_test', payload4);
  print('Insert 10000 rows took: \${DateTime.now().difference(start4).inMilliseconds}ms');
  print('Row count: \${await getRowCount("batch_test")}');
  final dupCheck = await db.rawQuery('SELECT server_id, COUNT(*) as c FROM master_data WHERE category="batch_test" GROUP BY server_id HAVING c > 1');
  print('Duplicate count: \${dupCheck.length}');

  print('\\n--- Phase 5: Out-of-Order Payload Validation ---');
  await db.delete('master_data', where: 'category = ?', whereArgs: ['order_test']);
  
  // Base state
  final baseItem = MasterDataSyncItem(
    serverId: 'o-1', category: 'order_test', key: 'O_1', value: 'Base Value',
    sortOrder: 1, version: 5, isActive: 1, serverUpdatedAt: '2026-06-01T00:00:00.000',
  );
  await syncService.processSyncPayload('order_test', [baseItem]);
  var sample = await repo.getMasterData('order_test');
  print('Base state: Version \${sample[0]["version"]}, Value: \${sample[0]["value"]}, Updated: \${sample[0]["server_updated_at"]}');
  
  // Scenario A: Incoming version = 4 (Expected: IGNORE)
  await syncService.processSyncPayload('order_test', [MasterDataSyncItem(
    serverId: 'o-1', category: 'order_test', key: 'O_1', value: 'Older Value',
    sortOrder: 1, version: 4, isActive: 1, serverUpdatedAt: '2026-06-02T00:00:00.000',
  )]);
  sample = await repo.getMasterData('order_test');
  print('After Scen A (v4): Version \${sample[0]["version"]}, Value: \${sample[0]["value"]}');

  // Scenario B: Incoming version = 5, newer updated_at (Expected: UPDATE)
  await syncService.processSyncPayload('order_test', [MasterDataSyncItem(
    serverId: 'o-1', category: 'order_test', key: 'O_1', value: 'Newer Date Value',
    sortOrder: 1, version: 5, isActive: 1, serverUpdatedAt: '2026-06-03T00:00:00.000',
  )]);
  sample = await repo.getMasterData('order_test');
  print('After Scen B (v5 newer): Version \${sample[0]["version"]}, Value: \${sample[0]["value"]}, Updated: \${sample[0]["server_updated_at"]}');

  // Scenario C: Incoming version = 6 (Expected: UPDATE)
  await syncService.processSyncPayload('order_test', [MasterDataSyncItem(
    serverId: 'o-1', category: 'order_test', key: 'O_1', value: 'Newer Version Value',
    sortOrder: 1, version: 6, isActive: 1, serverUpdatedAt: '2026-06-03T00:00:00.000', // same date, but higher version
  )]);
  sample = await repo.getMasterData('order_test');
  print('After Scen C (v6): Version \${sample[0]["version"]}, Value: \${sample[0]["value"]}');

  // Scenario D: Incoming version = 5 after version = 6 (Expected: IGNORE)
  await syncService.processSyncPayload('order_test', [MasterDataSyncItem(
    serverId: 'o-1', category: 'order_test', key: 'O_1', value: 'Rogue Older Version',
    sortOrder: 1, version: 5, isActive: 1, serverUpdatedAt: '2026-06-04T00:00:00.000', // very new date, but old version
  )]);
  sample = await repo.getMasterData('order_test');
  print('After Scen D (rogue v5): Version \${sample[0]["version"]}, Value: \${sample[0]["value"]}');

  print('\\n--- Phase 6: Duplicate Replay Validation ---');
  await db.delete('master_data', where: 'category = ?', whereArgs: ['dup_test']);
  final dupPayload = [MasterDataSyncItem(
    serverId: 'd-1', category: 'dup_test', key: 'D_1', value: 'Dup Val',
    sortOrder: 1, version: 1, isActive: 1, serverUpdatedAt: '2026-06-01T00:00:00.000',
  )];
  await syncService.processSyncPayload('dup_test', dupPayload);
  final firstSample = await repo.getMasterData('dup_test');
  final firstUuid = firstSample[0]['local_uuid'];
  print('Initial Row count: \${await getRowCount("dup_test")}, UUID: \$firstUuid');

  for (int i=0; i<10; i++) {
    await syncService.processSyncPayload('dup_test', dupPayload);
  }
  final secondSample = await repo.getMasterData('dup_test');
  print('After 10 replays Row count: \${await getRowCount("dup_test")}, UUID: \${secondSample[0]["local_uuid"]}, Version: \${secondSample[0]["version"]}');

  print('\\n--- Phase 7: Extreme Scale Validation ---');
  final start7 = DateTime.now();
  final scalePayload = List.generate(100000, (i) => MasterDataSyncItem(
    serverId: 's-$i', category: 'scale_test', key: 'S_$i', value: 'V $i',
    sortOrder: 1, version: 1, isActive: 1, serverUpdatedAt: '2026-06-01T00:00:00.000',
  ));
  await syncService.processSyncPayload('scale_test', scalePayload);
  print('Generated 100,000 scale rows in \${DateTime.now().difference(start7).inMilliseconds}ms');

  final start7mix = DateTime.now();
  final mixedPayload = List.generate(10000, (i) {
    // Some are older versions, some are newer versions
    final v = i % 2 == 0 ? 0 : 2; // Evens are older (v=0), Odds are newer (v=2)
    return MasterDataSyncItem(
      serverId: 's-\${i * 10}', category: 'scale_test', key: 'S_\${i * 10}', value: 'Mixed $i',
      sortOrder: 1, version: v, isActive: 1, serverUpdatedAt: '2026-06-02T00:00:00.000',
    );
  });
  await syncService.processSyncPayload('scale_test', mixedPayload);
  print('Processed 10,000 mixed updates in \${DateTime.now().difference(start7mix).inMilliseconds}ms');

  final start7lookup = DateTime.now();
  await repo.getMasterData('scale_test', parentKey: 'NON_EXISTENT');
  print('Lookup query on 100000 rows took: \${DateTime.now().difference(start7lookup).inMilliseconds}ms');

  print('\\n--- Phase 8: Seeder Compatibility Regression ---');
  final seederCount1 = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) as c FROM master_data WHERE category="Banks"')) ?? 0;
  print('Banks before seed: \$seederCount1');
  await db.delete('master_data', where: 'sync_source = ? AND category = ?', whereArgs: ['SEED', 'species']);
  await MasterDataSeeder.seedIfNeeded();
  final seederCount2 = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) as c FROM master_data WHERE category="Banks"')) ?? 0;
  print('Banks after seed: \$seederCount2');

  print('\\n=============================================');
  print('=== M14.4 VALIDATION RUN COMPLETED ===');
  print('=============================================');
  exit(0);
}
