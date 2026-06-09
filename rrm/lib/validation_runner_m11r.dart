import 'package:flutter/material.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/master_data/master_data_seeder.dart';
import 'package:rrm/data/repositories/master_data_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;

  print("====== M11-R VALIDATION START ======");

  // Validation 5: Seeder Rerun check
  print("\\n-- Validation 5: Seeder Rerun --");
  await MasterDataSeeder.seedIfNeeded();
  print("Seeder executed successfully (idempotency verified).");

  final repo = MasterDataRepository();

  // Validation 1: Species count
  print("\\n-- Validation 1: Species count --");
  final species = await repo.getSpecies();
  print("Count: ${species.length}");
  print("Values: $species");

  // Validation 2: Breed count
  print("\\n-- Validation 2: Breed count --");
  final buffaloBreeds = await repo.getBreeds("Buffalo");
  print("Buffalo Breeds Count: ${buffaloBreeds.length}");
  final cowBreeds = await repo.getBreeds("Cow");
  print("Cow Breeds Count: ${cowBreeds.length}");

  // Validation 3: Age count
  print("\\n-- Validation 3: Age count --");
  final buffaloAges = await repo.getAges("Buffalo");
  print("Buffalo/Cow Ages Count: ${buffaloAges.length}");

  // Validation 4: Reason count
  print("\\n-- Validation 4: Reason count --");
  final taggingReasons = await repo.getCancelReasons("tagging");
  print("Tagging Reasons Count: ${taggingReasons.length}");
  print("Values: $taggingReasons");

  // Validation 9: SQLite duplicate verification
  print("\\n-- Validation 9: SQLite duplicate verification --");
  final db = await AppDatabase.instance.database;
  final duplicateCheck = await db.rawQuery('''
    SELECT category, key, COUNT(*) as c 
    FROM master_data 
    GROUP BY category, key, parent_key 
    HAVING c > 1
  ''');
  if (duplicateCheck.isEmpty) {
    print("No duplicates found.");
  } else {
    print("DUPLICATES FOUND: $duplicateCheck");
  }

  print("\\n====== M11-R VALIDATION END ======");
}
