import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:rrm/data/repositories/base_repository.dart';
import 'package:rrm/data/models/draft_dashboard_item.dart';

class DraftRepository extends BaseRepository {
  /// Fetches all active drafts, pending syncs, dead letters, and conflicts.
  Future<List<DraftDashboardItem>> fetchDashboardDrafts() async {
    final database = await db;

    // We join leads with draft_progress to get the workflow state,
    // and sync_queue to check for failures/dead letters.
    // Assuming lead.local_uuid is the primary entity_uuid used in sync_queue.
    final String query = '''
      SELECT 
        l.local_uuid as entity_uuid,
        l.workflow_type,
        l.owner_name,
        l.mobile_number,
        l.village,
        l.total_cattle_count,
        l.sync_status,
        l.updated_at,
        dp.current_step,
        dp.last_screen_route,
        dp.completion_percentage,
        sq.last_error
      FROM leads l
      LEFT JOIN draft_progress dp ON l.local_uuid = dp.entity_uuid
      LEFT JOIN sync_queue sq ON l.local_uuid = sq.entity_uuid AND sq.status = 'DEAD_LETTER'
      WHERE l.deleted_at IS NULL 
        AND l.sync_status IN ('DRAFT', 'COMPLETED_LOCALLY', 'PENDING_SYNC', 'SYNCING', 'DEAD_LETTER', 'CONFLICT')
      ORDER BY l.updated_at DESC
    ''';

    final result = await database.rawQuery(query);
    return result.map((e) => DraftDashboardItem.fromMap(e)).toList();
  }

  /// Deletes a draft completely.
  Future<void> deleteDraft(String localUuid) async {
    final database = await db;

    await database.transaction((txn) async {
      // 1. Fetch media_metadata absolute paths to delete physically
      final mediaRows = await txn.query('media_metadata', where: 'lead_uuid = ?', whereArgs: [localUuid]);
      for (var row in mediaRows) {
        final path = row['absolute_local_path'] as String?;
        if (path != null && path.isNotEmpty) {
          try {
            final file = File(path);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            print('Error deleting media file: $e');
          }
        }
      }

      // 2. Delete media metadata rows
      await txn.delete('media_metadata', where: 'lead_uuid = ?', whereArgs: [localUuid]);
      
      // 3. Delete cattle rows
      await txn.delete('cattle', where: 'lead_uuid = ?', whereArgs: [localUuid]);
      
      // 4. Delete leads row
      await txn.delete('leads', where: 'local_uuid = ?', whereArgs: [localUuid]);
      
      // 5. Delete draft_progress row
      await txn.delete('draft_progress', where: 'entity_uuid = ?', whereArgs: [localUuid]);
      
      // 6. Delete sync_queue row
      await txn.delete('sync_queue', where: 'entity_uuid = ?', whereArgs: [localUuid]);
    });
  }

  /// Retries a dead letter sync by resetting its status
  Future<void> retryDraft(String localUuid) async {
    final database = await db;
    await database.update(
      'sync_queue',
      {
        'status': 'PENDING',
        'attempt_count': 0,
        'next_retry_at': null,
        'last_error': null,
        'updated_at': DateTime.now().toIso8601String()
      },
      where: 'entity_uuid = ? AND status = ?',
      whereArgs: [localUuid, 'DEAD_LETTER'],
    );
  }

  /// Updates or inserts the progress tracking for a draft
  Future<void> saveDraftProgress({
    required String entityUuid,
    required String workflowType,
    required int currentStep,
    required String lastScreenRoute,
    required double completionPercentage,
  }) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();
    
    await database.insert(
      'draft_progress',
      {
        'entity_uuid': entityUuid,
        'workflow_type': workflowType,
        'current_step': currentStep,
        'last_screen_route': lastScreenRoute,
        'completion_percentage': completionPercentage,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
