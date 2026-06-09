import 'dart:async';
import 'package:rrm/core/database/app_database.dart';

import 'queue_processor.dart';
import 'connectivity_monitor.dart';
import 'sync_mutex.dart';

class SyncCoordinator {
  final QueueProcessor queueProcessor;
  final ConnectivityMonitor connectivityMonitor;
  final SyncMutex _mutex = SyncMutex();

  StreamSubscription<bool>? _connectivitySub;

  SyncCoordinator({
    required this.queueProcessor,
    required this.connectivityMonitor,
  });

  /// Initializes the coordinator: recovers stuck jobs and starts listening to network
  Future<void> initialize() async {
    await recoverCrashLocks();
    await recoverDeadLetters();

    _connectivitySub = connectivityMonitor.connectivityStream.listen((isOnline) {
      if (isOnline) {
        syncNow();
      }
    });
  }

  /// Finds IN_PROGRESS jobs stuck for more than 15 minutes and reverts them to PENDING
  Future<void> recoverCrashLocks() async {
    final db = await AppDatabase.instance.database;
    
    // ISO8601 string comparison is lexicographical, so we calculate threshold string
    final threshold = DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String();

    await db.rawUpdate('''
      UPDATE sync_queue 
      SET status = 'PENDING' 
      WHERE status = 'IN_PROGRESS' 
      AND processing_started_at IS NOT NULL 
      AND processing_started_at < ?
    ''', [threshold]);
    
    // Clear stale DB mutex if any
    await _mutex.clearStaleLock(db);
  }

  /// Automatically retries DEAD_LETTER jobs older than 72h exactly once
  Future<void> recoverDeadLetters() async {
    final db = await AppDatabase.instance.database;
    final threshold = DateTime.now().subtract(const Duration(hours: 72)).toIso8601String();

    await db.rawUpdate('''
      UPDATE sync_queue 
      SET status = 'PENDING', updated_at = ?
      WHERE status = 'DEAD_LETTER' 
      AND updated_at < ?
      AND attempt_count <= 6
    ''', [DateTime.now().toIso8601String(), threshold]);
  }

  /// Triggers a queue processing loop manually if network is available
  Future<void> syncNow() async {
    if (!connectivityMonitor.isOnline) {
      return;
    }

    final acquired = await _mutex.acquireLock();
    if (!acquired) {
      return; // Concurrency protection via DB Mutex
    }

    try {
      await queueProcessor.processQueue();
    } finally {
      await _mutex.releaseLock();
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}
