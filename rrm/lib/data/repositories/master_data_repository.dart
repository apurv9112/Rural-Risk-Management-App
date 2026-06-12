import 'package:uuid/uuid.dart';
import 'base_repository.dart';

class MasterDataRepository extends BaseRepository {
  Future<void> saveMasterData(
    String category,
    List<Map<String, dynamic>> items, {
    bool isServerSync = false,
  }) async {
    final database = await db;
    final serverUpdatedAt = DateTime.now().toIso8601String();
    final syncSource = isServerSync ? 'SERVER' : 'SEED';

    await database.transaction((txn) async {
      for (var item in items) {
        final key = item['key'];
        final serverId = item['server_id'];

        List<Map<String, dynamic>> existing = [];
        if (serverId != null) {
          existing = await txn.query(
            'master_data',
            where: 'server_id = ?',
            whereArgs: [serverId],
          );
        }
        if (existing.isEmpty && key != null) {
          existing = await txn.query(
            'master_data',
            where: 'category = ? AND key = ?',
            whereArgs: [category, key],
          );
        }

        if (existing.isNotEmpty) {
          final existingRow = existing.first;
          final existingSource = existingRow['sync_source'];

          // Rule: Seeder may NOT update SERVER rows
          if (!isServerSync && existingSource == 'SERVER') {
            continue;
          }

          final updateData = {
            'value': item['value'],
            'parent_key': item['parent_key'],
            'is_active': item['is_active'] ?? 1,
            'server_updated_at': serverUpdatedAt,
            'sync_source': syncSource,
            'deleted_at': item['deleted_at'],
          };
          if (serverId != null) updateData['server_id'] = serverId;

          await txn.update(
            'master_data',
            updateData,
            where: 'local_uuid = ?',
            whereArgs: [existingRow['local_uuid']],
          );
        } else {
          await txn.insert('master_data', {
            'local_uuid': const Uuid().v4(),
            'server_id': serverId,
            'category': category,
            'key': key,
            'value': item['value'],
            'parent_key': item['parent_key'],
            'is_active': item['is_active'] ?? 1,
            'server_updated_at': serverUpdatedAt,
            'sync_source': syncSource,
            'deleted_at': item['deleted_at'],
          });
        }
      }
    });
  }

  /// High performance batch upsert for sync engine (100k+ rows)
  Future<void> saveMasterDataBatch(
    String category,
    List<Map<String, dynamic>> items, {
    bool isServerSync = false,
    Map<String, dynamic>? syncStateUpdate,
  }) async {
    final database = await db;
    final fallbackUpdatedAt = DateTime.now().toIso8601String();
    final syncSource = isServerSync ? 'SERVER' : 'SEED';

    await database.transaction((txn) async {
      // 1. Fetch all existing rows for this category into memory to prevent platform channel loops
      final existingRowsList = await txn.query(
        'master_data',
        where: 'category = ?',
        whereArgs: [category],
      );

      // Index them by server_id and key for instant O(1) correlation
      final Map<String, Map<String, dynamic>> existingByServerId = {};
      final Map<String, Map<String, dynamic>> existingByKey = {};

      for (var row in existingRowsList) {
        if (row['server_id'] != null) {
          existingByServerId[row['server_id'].toString()] = row;
        }
        if (row['key'] != null) existingByKey[row['key'].toString()] = row;
      }

      // 2. Prepare single batch
      final batch = txn.batch();

      // 3. Correlate and apply
      for (var item in items) {
        final key = item['key'];
        final serverId = item['server_id'];

        Map<String, dynamic>? existingRow;
        if (serverId != null) {
          existingRow = existingByServerId[serverId.toString()];
        }
        if (existingRow == null && key != null) {
          existingRow = existingByKey[key.toString()];
        }

        if (existingRow != null) {
          final existingSource = existingRow['sync_source'];

          // Rule: Seeder may NOT update SERVER rows
          if (!isServerSync && existingSource == 'SERVER') {
            continue;
          }

          final existingVersion = existingRow['version'] as int? ?? 1;
          final incomingVersion = item['version'] as int? ?? 1;

          if (incomingVersion < existingVersion) {
            continue; // Ignore older versions
          }

          if (incomingVersion == existingVersion) {
            final existingDateStr = existingRow['server_updated_at'] as String?;
            final incomingDateStr = item['server_updated_at'] as String?;

            if (existingDateStr != null && incomingDateStr != null) {
              try {
                final existingDate = DateTime.parse(existingDateStr);
                final incomingDate = DateTime.parse(incomingDateStr);
                if (!incomingDate.isAfter(existingDate)) {
                  continue; // Ignore if incoming date is not strictly newer
                }
              } catch (_) {
                // If parsing fails, fall through and allow update
              }
            } else if (incomingDateStr == null) {
              continue; // If no incoming date, assume not newer
            }
          }

          final updateData = {
            'value': item['value'],
            'parent_key': item['parent_key'],
            'is_active': item['is_active'] ?? 1,
            'version': incomingVersion,
            'sort_order': item['sort_order'] ?? 0,
            'server_updated_at': item['server_updated_at'] ?? fallbackUpdatedAt,
            'sync_source': syncSource,
            'deleted_at': item['deleted_at'],
          };
          if (serverId != null) updateData['server_id'] = serverId;

          batch.update(
            'master_data',
            updateData,
            where: 'local_uuid = ?',
            whereArgs: [existingRow['local_uuid']],
          );
        } else {
          batch.insert('master_data', {
            'local_uuid': const Uuid().v4(),
            'server_id': serverId,
            'category': category,
            'key': key,
            'value': item['value'],
            'parent_key': item['parent_key'],
            'is_active': item['is_active'] ?? 1,
            'version': item['version'] ?? 1,
            'sort_order': item['sort_order'] ?? 0,
            'server_updated_at': item['server_updated_at'] ?? fallbackUpdatedAt,
            'sync_source': syncSource,
            'deleted_at': item['deleted_at'],
          });
        }
      }

      if (syncStateUpdate != null) {
        final existingState = await txn.query(
          'master_data_sync_state',
          where: 'category = ?',
          whereArgs: [syncStateUpdate['category']],
        );
        if (existingState.isNotEmpty) {
          batch.update(
            'master_data_sync_state',
            syncStateUpdate,
            where: 'category = ?',
            whereArgs: [syncStateUpdate['category']],
          );
        } else {
          batch.insert('master_data_sync_state', syncStateUpdate);
        }
      }

      // 4. Commit batch locally via C API (millisecond execution)
      await batch.commit(noResult: true);
    });
  }

  Future<Map<String, dynamic>?> getSyncState(String category) async {
    final database = await db;
    final result = await database.query(
      'master_data_sync_state',
      where: 'category = ?',
      whereArgs: [category],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get master data by category, optionally filtering by parent_key
  Future<List<Map<String, dynamic>>> getMasterData(
    String category, {
    String? parentKey,
  }) async {
    final database = await db;

    String whereClause =
        'category = ? AND is_active = 1 AND deleted_at IS NULL';
    List<dynamic> whereArgs = [category];

    if (parentKey != null) {
      whereClause += ' AND parent_key = ?';
      whereArgs.add(parentKey);
    }

    // Sort by sort_order first, falling back to rowid (insertion order)
    final result = await database.query(
      'master_data',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'sort_order ASC, rowid ASC',
    );

    return result;
  }

  Future<List<String>> _getStrings(String category, {String? parentKey}) async {
    final data = await getMasterData(category, parentKey: parentKey);
    return data.map((e) => e['value'].toString()).toList();
  }

  // ---- M11-R Specific Getters ----
  Future<List<String>> getSpecies() => _getStrings('species');
  Future<List<String>> getBreeds(String species) =>
      _getStrings('breeds', parentKey: species);
  Future<List<String>> getAges(String species) =>
      _getStrings('ages', parentKey: species);
  Future<List<String>> getBodyColors(String species) =>
      _getStrings('body_colors', parentKey: species);
  Future<List<String>> getHornTypes(String species) =>
      _getStrings('horn_types', parentKey: species);
  Future<List<String>> getTailColors() => _getStrings('tail_colors');
  Future<List<String>> getIdMarks() => _getStrings('id_marks');
  Future<List<String>> getLactations() => _getStrings('lactations');
  Future<List<String>> getMilkDays() => _getStrings('milk_days');
  Future<List<String>> getCancelReasons(String type) =>
      _getStrings('cancel_reasons', parentKey: type);
  Future<List<String>> getSpeciesNotAvailable() =>
      _getStrings('species_not_available');

  // ---- M11.5 Future Expansion Category Framework ----
  Future<List<String>> getStates() => _getStrings('states');
  Future<List<String>> getDistricts(String state) =>
      _getStrings('districts', parentKey: state);
  Future<List<String>> getTalukas(String district) =>
      _getStrings('talukas', parentKey: district);
  Future<List<String>> getVillages(String taluka) =>
      _getStrings('villages', parentKey: taluka);
  Future<List<String>> getBanks() => _getStrings('banks');
  Future<List<String>> getBranches(String bank) =>
      _getStrings('branches', parentKey: bank);
  Future<List<String>> getInsuranceCompanies() =>
      _getStrings('insurance_companies');

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
