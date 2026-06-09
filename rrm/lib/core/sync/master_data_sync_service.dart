import 'package:rrm/data/repositories/master_data_repository.dart';
import 'package:rrm/data/models/master_data_sync_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rrm/core/database/app_database.dart';

class MasterDataSyncService {
  final MasterDataRepository _repository = MasterDataRepository();

  /// Process a payload of MasterDataSyncItem models in chunks.
  Future<void> processSyncPayload(String category, List<MasterDataSyncItem> payload) async {
    const chunkSize = 1000;
    
    // Chunk processing
    for (int i = 0; i < payload.length; i += chunkSize) {
      final chunk = payload.skip(i).take(chunkSize).toList();
      final maps = chunk.map((item) => item.toDatabaseMap()).toList();
      
      // Upsert using the batch optimized path
      await _repository.saveMasterDataBatch(category, maps, isServerSync: true);
    }
    
    // Update cursor
    if (payload.isNotEmpty) {
      // Find the most recent server_updated_at in this payload
      String? latestServerUpdated;
      for (var item in payload) {
        if (latestServerUpdated == null || item.serverUpdatedAt.compareTo(latestServerUpdated) > 0) {
          latestServerUpdated = item.serverUpdatedAt;
        }
      }
      
      if (latestServerUpdated != null) {
        await _updateSyncCursor(category, latestServerUpdated);
      }
    }
  }

  /// Updates the delta cursor for a specific category
  Future<void> _updateSyncCursor(String category, String lastServerUpdatedAt) async {
    final database = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();
    
    await database.transaction((txn) async {
      final existing = await txn.query('master_data_sync_state', where: 'category = ?', whereArgs: [category]);
      
      if (existing.isEmpty) {
        await txn.insert('master_data_sync_state', {
          'category': category,
          'last_server_updated_at': lastServerUpdatedAt,
          'last_sync_at': now,
        });
      } else {
        await txn.update(
          'master_data_sync_state',
          {
            'last_server_updated_at': lastServerUpdatedAt,
            'last_sync_at': now,
          },
          where: 'category = ?',
          whereArgs: [category],
        );
      }
    });
  }

  /// Get the current delta cursor for a category
  Future<String?> getDeltaCursor(String category) async {
    final database = await AppDatabase.instance.database;
    final result = await database.query(
      'master_data_sync_state',
      columns: ['last_server_updated_at'],
      where: 'category = ?',
      whereArgs: [category],
    );
    
    if (result.isNotEmpty) {
      return result.first['last_server_updated_at'] as String?;
    }
    return null;
  }
}
