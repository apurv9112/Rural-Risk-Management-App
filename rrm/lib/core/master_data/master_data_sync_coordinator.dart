import 'package:flutter/foundation.dart';
import 'package:rrm/data/repositories/master_data_repository.dart';
import 'package:uuid/uuid.dart';

// Mock MasterDataService to simulate pagination fetch for validation
abstract class MasterDataSyncClient {
  Future<Map<String, dynamic>> fetchPage(
    String category,
    int page,
    int pageSize,
  );
}

class MasterDataSyncCoordinator {
  final MasterDataRepository _repository;
  final MasterDataSyncClient _client;

  // In-memory lock to prevent concurrent triggers for the same category
  static final Map<String, bool> _activeLocks = {};

  MasterDataSyncCoordinator(this._repository, this._client);

  Future<void> syncCategory(String category) async {
    // 1. Concurrent Trigger Protection
    if (_activeLocks[category] == true) {
      debugPrint('Sync already active for category: $category. Skipping.');
      return;
    }
    _activeLocks[category] = true;

    try {
      // 2. Recover Crash or Stale IN_PROGRESS (>15 mins)
      final state = await _repository.getSyncState(category);
      int currentPage = 1;
      int totalPages = 1;
      String syncSessionId = const Uuid().v4();
      String startedAt = DateTime.now().toIso8601String();

      if (state != null) {
        if (state['sync_status'] == 'IN_PROGRESS') {
          final updatedAt = DateTime.parse(state['updated_at'] as String);
          final age = DateTime.now().difference(updatedAt).inMinutes;

          if (age > 15) {
            debugPrint(
              'Recovering stale IN_PROGRESS sync for $category (Age: $age mins)',
            );
            currentPage = (state['current_page'] as int?) ?? 1;
            totalPages = (state['total_pages'] as int?) ?? 1;
            syncSessionId =
                (state['sync_session_id'] as String?) ?? syncSessionId;
            startedAt = (state['started_at'] as String?) ?? startedAt;
          } else {
            debugPrint(
              'Valid IN_PROGRESS sync for $category detected. Aborting duplicate.',
            );
            return;
          }
        } else if (state['sync_status'] == 'FAILED') {
          currentPage = (state['current_page'] as int?) ?? 1;
          totalPages = (state['total_pages'] as int?) ?? 1;
          syncSessionId =
              (state['sync_session_id'] as String?) ?? syncSessionId;
          startedAt = (state['started_at'] as String?) ?? startedAt;
        } else {
          // Already COMPLETED, start fresh delta
          // Assuming full refresh simulation
          currentPage = 1;
        }
      }

      debugPrint('Starting/Resuming sync for $category at Page $currentPage');

      while (currentPage <= totalPages) {
        // Update state to IN_PROGRESS (if not already)
        await _updateState(category, {
          'category': category,
          'sync_session_id': syncSessionId,
          'current_page': currentPage,
          'total_pages': totalPages,
          'sync_status': 'IN_PROGRESS',
          'started_at': startedAt,
          'updated_at': DateTime.now().toIso8601String(),
        });

        try {
          // Fetch Page
          final response = await _client.fetchPage(category, currentPage, 100);
          final itemsRaw = response['items'] as List<dynamic>? ?? [];
          totalPages = response['total_pages'] as int? ?? totalPages;
          final lastServerUpdatedAt =
              response['last_server_updated_at'] as String?;

          final items = itemsRaw.cast<Map<String, dynamic>>();

          // Advance logic
          int nextPage = currentPage + 1;
          String status = nextPage > totalPages ? 'COMPLETED' : 'IN_PROGRESS';
          String? completedAt = status == 'COMPLETED'
              ? DateTime.now().toIso8601String()
              : null;

          final stateUpdate = {
            'category': category,
            'sync_session_id': syncSessionId,
            'current_page': nextPage > totalPages ? totalPages : nextPage,
            'total_pages': totalPages,
            'sync_status': status,
            'last_server_updated_at':
                lastServerUpdatedAt ?? state?['last_server_updated_at'],
            'started_at': startedAt,
            'completed_at': completedAt ?? state?['completed_at'],
            'updated_at': DateTime.now().toIso8601String(),
          };

          if (status == 'COMPLETED') {
            stateUpdate['last_successful_sync_at'] = DateTime.now()
                .toIso8601String();
          }

          // Atomic Save
          await _repository.saveMasterDataBatch(
            category,
            items,
            isServerSync: true,
            syncStateUpdate: stateUpdate,
          );

          debugPrint('Committed page $currentPage/$totalPages for $category');

          if (status == 'COMPLETED') {
            break;
          }
          currentPage = nextPage;
        } catch (e) {
          debugPrint('Error syncing page $currentPage for $category: $e');
          await _updateState(category, {
            'category': category,
            'sync_status': 'FAILED',
            'last_error': e.toString(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          break; // Stop loop on error
        }
      }
    } finally {
      _activeLocks[category] = false;
    }
  }

  Future<void> _updateState(
    String category,
    Map<String, dynamic> stateUpdate,
  ) async {
    final db = await _repository.db;
    final existing = await db.query(
      'master_data_sync_state',
      where: 'category = ?',
      whereArgs: [category],
    );
    if (existing.isNotEmpty) {
      await db.update(
        'master_data_sync_state',
        stateUpdate,
        where: 'category = ?',
        whereArgs: [category],
      );
    } else {
      await db.insert('master_data_sync_state', stateUpdate);
    }
  }
}
