import 'package:flutter/foundation.dart';
import 'package:rrm/data/repositories/master_data_repository.dart';
import 'package:rrm/services/master_data_service.dart';

class MasterDataManager {
  static final MasterDataManager _instance = MasterDataManager._internal();
  factory MasterDataManager() => _instance;
  MasterDataManager._internal();

  final MasterDataRepository _repository = MasterDataRepository();
  final MasterDataService _service = MasterDataService();

  /// Call this when app initializes or on successful login
  Future<void> syncMasterDataIfNeeded(String token) async {
    try {
      // For this phase, we group everything into a single 'master_data' category check
      // or we can check the age of the oldest master data item.
      final lastRefresh = await _repository.getLastRefreshTime('reasons');
      
      final now = DateTime.now();
      if (lastRefresh == null || now.difference(lastRefresh).inDays >= 7) {
        debugPrint("Master Data is older than 7 days or missing. Fetching...");
        await forceSyncMasterData(token);
      } else {
        debugPrint("Master Data is up to date (Age: ${now.difference(lastRefresh).inDays} days).");
      }
    } catch (e) {
      debugPrint("Master Data sync error: $e");
    }
  }

  /// Force a fresh download and replace local cache
  Future<void> forceSyncMasterData(String token) async {
    try {
      final items = await _service.fetchMasterData(token);
      
      // Group items by category to batch save them
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var item in items) {
        final cat = item['category'] as String;
        grouped.putIfAbsent(cat, () => []).add(item);
      }

      for (var entry in grouped.entries) {
        await _repository.saveMasterData(entry.key, entry.value);
      }
      
      debugPrint("Master Data successfully synced and cached offline.");
    } catch (e) {
      debugPrint("Failed to force sync Master Data: $e");
    }
  }

  /// Get offline cached data
  Future<List<Map<String, dynamic>>> getMasterData(String category, {String? parentKey}) async {
    return await _repository.getMasterData(category, parentKey: parentKey);
  }

  /// Clear all offline data
  Future<void> clearMasterData() async {
    await _repository.clearMasterData();
  }
}
