import 'package:flutter/foundation.dart';
import '../../core/database/app_database.dart';

class QueueCleanupService {
  static const int batchSize = 100;
  static const int retentionDays = 7;

  /// Retrieves the cutoff date. Jobs older than this are candidates for cleanup.
  static Future<DateTime?> calculateRetentionCutoff() async {
    return DateTime.now().subtract(const Duration(days: retentionDays));
  }

  /// Non-blocking, batched, WAL-safe cleanup loop for COMPLETED queue jobs.
  static Future<void> executeCleanup() async {
    final db = await AppDatabase.instance.database;
    final cutoff = await calculateRetentionCutoff();
    if (cutoff == null) return;
    final cutoffIso = cutoff.toIso8601String();

    bool hasMore = true;

    while (hasMore) {
      try {
        final List<Map<String, dynamic>> batch = await db.query(
          'sync_queue',
          columns: ['queue_uuid'],
          where: 'status = ? AND updated_at < ?',
          whereArgs: ['COMPLETED', cutoffIso],
          limit: batchSize,
        );

        if (batch.isEmpty) {
          hasMore = false;
          break;
        }

        int deletedCount = 0;
        // Process sequentially to be non-blocking and WAL safe.
        for (final row in batch) {
          final queueUuid = row['queue_uuid'] as String;
          try {
            await db.delete('sync_queue', where: 'queue_uuid = ?', whereArgs: [queueUuid]);
            deletedCount++;
          } catch (e) {
            debugPrint("Failed to cleanup queue job $queueUuid: $e");
          }
        }

        // Add a micro-delay to yield the event loop to UI interactions
        await Future.delayed(const Duration(milliseconds: 10));
        
        if (deletedCount == 0) {
          // If we couldn't delete anything, prevent infinite loop
          hasMore = false;
        }
      } catch (e) {
        debugPrint("Error during queue cleanup batch: $e");
        hasMore = false; // abort safely on massive DB failure
      }
    }
  }
}
