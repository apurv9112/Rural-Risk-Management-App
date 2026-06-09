import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'sync_coordinator.dart';
import 'queue_processor.dart';
import 'connectivity_monitor.dart';
import '../../data/repositories/sync_queue_repository.dart';
import 'executors/http_queue_executor.dart';
import '../database/app_database.dart';
import 'queue_cleanup_service.dart';

const syncTaskName = 'rrm_background_sync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Native called background task: $task');
    try {
      // 1. Re-initialize Database in the isolated background context
      await AppDatabase.instance.database;

      // 2. Instantiate SyncCoordinator
      final repository = SyncQueueRepository();
      final executor = HttpQueueExecutor();
      final queueProcessor = QueueProcessor(repository: repository, executor: executor);
      final connectivityMonitor = ConnectivityMonitor();

      final coordinator = SyncCoordinator(
        queueProcessor: queueProcessor,
        connectivityMonitor: connectivityMonitor,
      );

      // 3. Recover any crash locks and dead letters
      await coordinator.recoverCrashLocks();
      await coordinator.recoverDeadLetters();

      // 4. Force a sync
      await coordinator.syncNow();

      // 5. Storage Cleanup Task
      await _cleanupOldMedia(AppDatabase.instance);
      await QueueCleanupService.executeCleanup();

      return Future.value(true);
    } catch (err) {
      debugPrint('Background Sync Error: $err');
      return Future.value(false); // Indicates failure, might be retried
    }
  });
}

Future<void> _cleanupOldMedia(AppDatabase appDb) async {
  try {
    final db = await appDb.database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
    
    // Find media synced > 7 days ago
    final oldMedia = await db.query(
      'media_metadata',
      where: 'sync_status = ? AND synced_at < ?',
      whereArgs: ['COMPLETED', sevenDaysAgo],
    );

    for (final media in oldMedia) {
      final path = media['absolute_local_path'] as String?;
      if (path != null) {
        final file = File(path);
        if (file.existsSync()) {
          await file.delete();
        }
      }
      // Optionally delete DB row or just keep it as metadata
      await db.delete('media_metadata', where: 'local_uuid = ?', whereArgs: [media['local_uuid']]);
    }
  } catch (e) {
    debugPrint('Media cleanup error: $e');
  }
}

class BackgroundSyncManager {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );

    // Register periodic task
    await Workmanager().registerPeriodicTask(
      '1', // Unique ID
      syncTaskName,
      frequency: const Duration(minutes: 15), // Android minimum is 15 minutes
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run if online
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
