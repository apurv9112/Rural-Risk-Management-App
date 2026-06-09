import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/data/repositories/master_data_repository.dart';
import 'package:rrm/core/database/migrations/migration_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:rrm/pages/tagging_data_screen.dart/tagging_data_controller.dart';
import 'package:rrm/core/master_data/master_data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=============================================');
  print('=== M14.1 HARDENING VALIDATION STARTING ===');
  print('=============================================');
  
  try {
    await runM14Validation();
  } catch (e) {
    print('EXCEPTION: $e');
  }
  
  print('=============================================');
  print('=== M14.1 HARDENING VALIDATION COMPLETED ===');
  print('=============================================');
  
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('M14.1 Validation Runner Finished')))));
}

Future<void> runM14Validation() async {
  // Wipe and create fresh to avoid isolates
  final dbPath = join(await getDatabasesPath(), 'rrm.db');
  await deleteDatabase(dbPath);
  final db = await AppDatabase.instance.database;
  
  final repo = MasterDataRepository();

  print('\\n--- Validation 1 - Index Existence ---');
  final idxRes = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='master_data'");
  bool idxLookup = false, idxServer = false, idxUpdated = false;
  for (final row in idxRes) {
    if (row['name'] == 'idx_master_data_lookup') idxLookup = true;
    if (row['name'] == 'idx_master_data_server') idxServer = true;
    if (row['name'] == 'idx_master_data_updated') idxUpdated = true;
  }
  print('idx_master_data_lookup exists: $idxLookup');
  print('idx_master_data_server exists: $idxServer');
  print('idx_master_data_updated exists: $idxUpdated');

  print('\\n--- Validation 2 - UPSERT & Server Identity ---');
  // Initial Sync
  await repo.saveMasterData('banks', [
    {'server_id': 'b1', 'key': 'BANK1', 'value': 'State Bank'}
  ], isServerSync: true);
  
  // Repeated UPSERT
  await repo.saveMasterData('banks', [
    {'server_id': 'b1', 'key': 'BANK1', 'value': 'State Bank of India'}
  ], isServerSync: true);

  final banks = await db.query('master_data', where: "category='banks'");
  print('Total Bank Rows (Expected 1): ${banks.length}');
  print('Bank Value: ${banks.first['value']}');
  final originalLocalUuid = banks.first['local_uuid'];

  // Add missing row
  await repo.saveMasterData('banks', [
    {'server_id': 'b1', 'key': 'BANK1', 'value': 'State Bank of India'},
    {'server_id': 'b2', 'key': 'BANK2', 'value': 'HDFC'}
  ], isServerSync: true);
  final banks2 = await db.query('master_data', where: "category='banks'");
  print('Total Bank Rows (Expected 2): ${banks2.length}');
  final b1 = banks2.firstWhere((b) => b['server_id'] == 'b1');
  print('Original local_uuid preserved: ${b1['local_uuid'] == originalLocalUuid}');

  print('\\n--- Validation 3 - Seeder Isolation ---');
  // Seeder tries to update SERVER row
  await repo.saveMasterData('banks', [
    {'key': 'BANK1', 'value': 'State Bank (Seeder Attempt)'}
  ], isServerSync: false); // SEED

  final banks3 = await db.query('master_data', where: "server_id='b1'");
  print('Value after seeder attempt (Expected State Bank of India): ${banks3.first['value']}');
  
  // Seeder tries to insert missing
  await repo.saveMasterData('banks', [
    {'key': 'BANK3', 'value': 'ICICI (Seed)'}
  ], isServerSync: false); // SEED
  final banks4 = await db.query('master_data', where: "key='BANK3'");
  print('Missing row inserted by seeder: ${banks4.isNotEmpty}');

  print('\\n--- Validation 4 - Soft Delete ---');
  await repo.saveMasterData('banks', [
    {'server_id': 'b1', 'key': 'BANK1', 'value': 'State Bank of India', 'deleted_at': DateTime.now().toIso8601String()}
  ], isServerSync: true);
  
  final allPhysical = await db.query('master_data', where: "server_id='b1'");
  print('Row still physical: ${allPhysical.isNotEmpty}');
  
  final logicalGet = await repo.getBanks();
  print('Row excluded from lookup: ${logicalGet.contains('State Bank of India') == false}');

  print('\\n--- Validation 5 - Scale Performance ---');
  print('Inserting 100k rows... (simulating Villages)');
  
  final batch = db.batch();
  for (int i = 0; i < 100000; i++) {
    batch.insert('master_data', {
      'local_uuid': const Uuid().v4(),
      'server_id': 'v$i',
      'category': 'villages',
      'key': 'V$i',
      'value': 'Village $i',
      'parent_key': 'TALUKA_${i % 1000}', // Distribute 100k villages across 1k talukas (100 each)
      'is_active': 1,
      'sync_source': 'SERVER',
    });
  }
  
  final startIns = DateTime.now();
  await batch.commit(noResult: true);
  print('Insert 100k took: ${DateTime.now().difference(startIns).inMilliseconds}ms');

  final startQ = DateTime.now();
  final result = await repo.getVillages('TALUKA_1');
  final qTime = DateTime.now().difference(startQ).inMilliseconds;
  print('Lookup query out of 100k took: ${qTime}ms for ${result.length} rows');
  print('Lookup query acceptable (< 100ms): ${qTime < 100}');

  print('\\n--- Validation 6 - Seeder Regression Audit ---');
  await MasterDataSeeder.seedIfNeeded();
  
  final species = await repo.getSpecies();
  print('TaggingDataController species loaded: ${species.isNotEmpty}');
  final colors = await repo.getTailColors();
  print('TaggingDataController tail_colors loaded: ${colors.isNotEmpty}');
}
