import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:rrm/core/database/app_database.dart';

class MasterDataSeeder {
  static Future<void> seedIfNeeded() async {
    final database = await AppDatabase.instance.database;

    // Check if seeder already ran (by checking if 'species' category has data)
    final countResult = await database.rawQuery(
      "SELECT count(*) as count FROM master_data WHERE category = 'species'",
    );
    int count = Sqflite.firstIntValue(countResult) ?? 0;

    if (count > 0) {
      debugPrint("MasterDataSeeder: Data already exists, skipping seed.");
      return;
    }

    debugPrint("MasterDataSeeder: Seeding master_data table...");
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> itemsToSeed = [];

    void addItems(String category, String? parentKey, List<String> values) {
      int index = 0;
      for (var val in values) {
        itemsToSeed.add({
          'local_uuid': const Uuid().v4(),
          'server_id': const Uuid()
              .v4(), // Generate temporary server_id for seeded data
          'sync_source': 'SEED',
          'version': 1,
          'category': category,
          'key': val,
          'value': val,
          'parent_key': parentKey,
          'is_active': 1,
          'sort_order': index,
          'server_updated_at': now,
          'updated_at': now,
        });
        index++;
      }
    }

    // 1. species_not_available
    addItems('species_not_available', null, [
      'Not Purchased',
      'Unhealthy Cattle',
      'Unproductive Cattle',
      'Under Value Cattle',
    ]);

    // 2. species
    addItems('species', null, ['Buffalo', 'Cow', 'Sheep', 'Goat']);

    // 3. ages (Mapped by species)
    addItems('ages', 'Buffalo', [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
    ]);
    addItems('ages', 'Cow', [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
    ]);
    addItems('ages', 'Sheep', [
      '1',
      '1.5',
      '2',
      '2.5',
      '3',
      '3.5',
      '4',
      '5',
      '6',
      '7',
    ]);
    addItems('ages', 'Goat', [
      '1',
      '1.5',
      '2',
      '2.5',
      '3',
      '3.5',
      '4',
      '5',
      '6',
      '7',
    ]);

    // 4. breeds
    addItems('breeds', 'Buffalo', [
      'Mehsani',
      'Surati',
      'Jafrabadi',
      'Murrah',
      'Banni',
    ]);
    addItems('breeds', 'Cow', [
      'HF.Cross',
      'Jr.Cross',
      'Kankrej',
      'Gir',
      'Rathi',
      'Nagori',
      'Shahiwal',
    ]);
    addItems('breeds', 'Sheep', [
      'Marwari',
      'Magra',
      'Chokla',
      'Nali',
      'Pugal',
      'Jaisalmeri',
      'Malpura',
      'Sonadi',
      'Patanwadi',
    ]);
    addItems('breeds', 'Goat', [
      'Kutchi',
      'Surti',
      'Zalawadi',
      'Mehsana',
      'Gohilwadi',
      'Kahmi',
      'Sirohi',
      'Marwari',
      'Jakhrana',
      'Sojat',
      'Karauli',
      'Gujari',
      'Jamunapari',
      'Barbari',
    ]);

    // 5. body_colors
    addItems('body_colors', 'Buffalo', ['Black', 'G.Black', 'Grey']);
    addItems('body_colors', 'Cow', [
      'Black',
      'Brown',
      'Br&Bl',
      'Bl&Wt',
      'O.White',
      'Br&Wt',
      'WHITE',
    ]);
    addItems('body_colors', 'Sheep', [
      'Black',
      'Brown',
      'Br&Bl',
      'Bl&Wt',
      'O.White',
      'Br&Wt',
      'Tan',
      'WHITE',
    ]);
    addItems('body_colors', 'Goat', [
      'Black',
      'Brown',
      'Br&Bl',
      'Bl&Wt',
      'O.White',
      'Br&Wt',
      'Tan',
      'WHITE',
    ]);

    // 6. horn_types (Right & Left are the same lists basically, so we map them as horn_types and the controller uses them for both)
    addItems('horn_types', 'Buffalo', [
      'Sideward',
      'Downward',
      'Rolled',
      'Curved',
      'Broken',
      'Sickle',
    ]);
    addItems('horn_types', 'Cow', [
      'Dehorned',
      'Forward',
      'Short',
      'Crescent',
      'Downward',
    ]);
    addItems('horn_types', 'Sheep', [
      'Polled',
      'Curved',
      'Twisted',
      'Spiral',
      'Button',
    ]);
    addItems('horn_types', 'Goat', [
      'Polled',
      'Curved',
      'Upward',
      'Spiral',
      'Sideward',
      'Scurs',
    ]);

    // 7. tail_colors
    addItems('tail_colors', null, ['Black', 'Gray', 'White', 'brown']);

    // 8. id_marks
    addItems('id_marks', null, ['Star', 'Nil']);

    // 9. lactations
    addItems('lactations', null, ['0', '1', '2', '3', '4', '5', '6', '7', '8']);

    // milk_days
    addItems('milk_days', null, [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
    ]);

    // 10. cancel_reasons
    addItems('cancel_reasons', 'tagging', [
      "Not Purchased",
      "Unhealthy Cattle",
      "Unproductive Cattle",
      "Under Value Cattle",
      "Insured Not Cooperating",
      "Insured Not Available",
      "Other",
    ]);
    addItems('cancel_reasons', 'retagging', [
      "Cattle Not Matching",
      "False Request",
      "Cattle Sold Out",
      "Other",
    ]);
    addItems('cancel_reasons', 'claim', [
      "Cattle Alive",
      "False Intimation",
      "Cattle Discarded",
      "Other",
    ]);

    await database.transaction((txn) async {
      for (var item in itemsToSeed) {
        // Enforce uniqueness check inside transaction just in case
        final exists = await txn.rawQuery(
          "SELECT 1 FROM master_data WHERE category = ? AND key = ? AND (parent_key = ? OR (parent_key IS NULL AND ? IS NULL))",
          [
            item['category'],
            item['key'],
            item['parent_key'],
            item['parent_key'],
          ],
        );

        if (exists.isEmpty) {
          await txn.insert(
            'master_data',
            item,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    });

    debugPrint(
      "MasterDataSeeder: Seed complete. Inserted ${itemsToSeed.length} potential items.",
    );
  }
}
