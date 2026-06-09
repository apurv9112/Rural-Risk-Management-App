import 'package:flutter/material.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/master_data/master_data_seeder.dart';
import 'package:rrm/data/repositories/master_data_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;

  print("====== M11.5 VALIDATION START ======");

  // Validate Migration
  print("\\n-- Validate Migration --");
  final db = await AppDatabase.instance.database;
  final columns = await db.rawQuery('PRAGMA table_info(master_data)');
  final columnNames = columns.map((c) => c['name']).toList();
  print("Columns: $columnNames");

  if (columnNames.contains('server_id') && columnNames.contains('sort_order')) {
    print("MIGRATION SUCCESSFUL.");
  } else {
    print("MIGRATION FAILED.");
  }

  // Validate Data Intact
  final repo = MasterDataRepository();
  print("\\n-- Validate Existing Data Intact --");
  final species = await repo.getSpecies();
  print("Species: $species");
  
  final buffaloBreeds = await repo.getBreeds("Buffalo");
  print("Buffalo Breeds: $buffaloBreeds");

  final reasons = await repo.getCancelReasons("tagging");
  print("Tagging Reasons: $reasons");

  // Validate Zero Data Loss
  final countRes = await db.rawQuery('SELECT COUNT(*) as c FROM master_data');
  print("Total Rows: ${countRes.first['c']}");

  print("\\n====== M11.5 VALIDATION END ======");
}
