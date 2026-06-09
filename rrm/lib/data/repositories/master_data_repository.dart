import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'base_repository.dart';

class MasterDataRepository extends BaseRepository {
  /// Save a batch of master data items for a specific category
  Future<void> saveMasterData(String category, List<Map<String, dynamic>> items) async {
    final database = await db;
    final serverUpdatedAt = DateTime.now().toIso8601String();

    await database.transaction((txn) async {
      // Clear existing active items for this category before inserting new ones
      await txn.delete(
        'master_data',
        where: 'category = ?',
        whereArgs: [category],
      );

      for (var item in items) {
        await txn.insert(
          'master_data',
          {
            'local_uuid': const Uuid().v4(),
            'category': category,
            'key': item['key'],
            'value': item['value'], // Expecting a JSON string or simple value
            'parent_key': item['parent_key'],
            'is_active': item['is_active'] ?? 1,
            'server_updated_at': serverUpdatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Get master data by category, optionally filtering by parent_key
  Future<List<Map<String, dynamic>>> getMasterData(String category, {String? parentKey}) async {
    final database = await db;
    
    String whereClause = 'category = ? AND is_active = 1';
    List<dynamic> whereArgs = [category];

    if (parentKey != null) {
      whereClause += ' AND parent_key = ?';
      whereArgs.add(parentKey);
    }

    final result = await database.query(
      'master_data',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'value ASC',
    );

    return result;
  }

  /// Get the last refresh time for a category
  Future<DateTime?> getLastRefreshTime(String category) async {
    final database = await db;
    final result = await database.query(
      'master_data',
      columns: ['server_updated_at'],
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'server_updated_at DESC',
      limit: 1,
    );

    if (result.isNotEmpty && result.first['server_updated_at'] != null) {
      return DateTime.parse(result.first['server_updated_at'] as String);
    }
    return null;
  }

  /// Clear all master data (e.g. on logout)
  Future<void> clearMasterData() async {
    final database = await db;
    await database.delete('master_data');
  }
}
