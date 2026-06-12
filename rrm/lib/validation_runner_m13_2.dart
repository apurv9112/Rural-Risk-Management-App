import 'package:flutter/material.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/data/repositories/sync_queue_repository.dart';
import 'package:rrm/core/sync/queue_cleanup_service.dart';
import 'package:rrm/core/sync/sync_coordinator.dart';
import 'package:rrm/core/sync/queue_processor.dart';
import 'package:rrm/core/sync/executors/http_queue_executor.dart';
import 'package:rrm/core/sync/connectivity_monitor.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=============================================');
  print('=== M13.2 HARDENING VALIDATION STARTING ===');
  print('=============================================');
  
  try {
    await runM13Validation();
  } catch (e) {
    print('EXCEPTION: $e');
  }
  
  print('=============================================');
  print('=== M13.2 HARDENING VALIDATION COMPLETED ===');
  print('=============================================');
  
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('M13.2 Validation Runner Finished')))));
}

Future<void> runM13Validation() async {
  // We force upgrade by opening DB, but first delete the old one to avoid background isolate transaction clashes!
  final dbPath = join(await getDatabasesPath(), 'rrm.db');
  await deleteDatabase(dbPath);

  final db = await AppDatabase.instance.database;
  final queueRepo = SyncQueueRepository();


  // Phase 1 - Idempotency Validation
  print('\\n--- Validation 1 - Idempotency Key Format ---');
  final v1Uuid = const Uuid().v4();
  final job1 = await queueRepo.createJob(
    entityType: 'lead', 
    entityUuid: v1Uuid, 
    operationType: 'CREATE', 
    payloadJson: '{}'
  );
  print('job1 idempotency_key = ${job1.idempotencyKey}');
  final job2 = await queueRepo.createJob(
    entityType: 'lead', 
    entityUuid: v1Uuid, 
    operationType: 'UPDATE', 
    payloadJson: '{}'
  );
  print('job2 idempotency_key = ${job2.idempotencyKey}');
  
  if (job1.idempotencyKey == 'lead:$v1Uuid:CREATE' && job2.idempotencyKey == 'lead:$v1Uuid:UPDATE') {
    print('Idempotency Validation: PASS');
  } else {
    print('Idempotency Validation: FAIL');
  }

  // Phase 2 - Queue Cleanup Service
  print('\\n--- Validation 2 - Queue Cleanup ---');
  await db.delete('sync_queue'); // clear table
  
  final oldDate = DateTime.now().subtract(const Duration(days: 10)).toIso8601String();
  
  // Insert Old Completed
  await db.insert('sync_queue', {
    'queue_uuid': 'c1', 'idempotency_key': 'k1', 'status': 'COMPLETED', 'updated_at': oldDate
  });
  // Insert New Completed
  await db.insert('sync_queue', {
    'queue_uuid': 'c2', 'idempotency_key': 'k2', 'status': 'COMPLETED', 'updated_at': DateTime.now().toIso8601String()
  });
  // Insert Old Pending
  await db.insert('sync_queue', {
    'queue_uuid': 'p1', 'idempotency_key': 'k3', 'status': 'PENDING', 'updated_at': oldDate
  });

  print('Before Cleanup:');
  final beforeCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sync_queue'));
  print('Total rows: $beforeCount');

  await QueueCleanupService.executeCleanup();

  print('After Cleanup:');
  final afterRes = await db.query('sync_queue', columns: ['queue_uuid', 'status']);
  for (final row in afterRes) {
    print('Remaining row: queue_uuid=${row['queue_uuid']}, status=${row['status']}');
  }

  // Phase 3 - Query Optimization (Index Validation)
  print('\\n--- Validation 3 - Index Existence ---');
  final idxRes = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='sync_queue'");
  bool idxFound = false;
  for (final row in idxRes) {
    if (row['name'] == 'idx_queue_sort') {
      idxFound = true;
    }
  }
  print('idx_queue_sort exists: $idxFound');

  // Phase 4 - Dead Letter Recovery
  print('\\n--- Validation 4 - Dead Letter Recovery ---');
  final dlOldDate = DateTime.now().subtract(const Duration(hours: 73)).toIso8601String();
  
  // Create old dead letter with attempt_count = 6
  await db.insert('sync_queue', {
    'queue_uuid': 'dl1', 'idempotency_key': 'k4', 'status': 'DEAD_LETTER', 
    'updated_at': dlOldDate, 'attempt_count': 6
  });
  // Create old dead letter with attempt_count = 7 (already recovered once and failed again)
  await db.insert('sync_queue', {
    'queue_uuid': 'dl2', 'idempotency_key': 'k5', 'status': 'DEAD_LETTER', 
    'updated_at': dlOldDate, 'attempt_count': 7
  });

  final executor = HttpQueueExecutor();
  final queueProcessor = QueueProcessor(repository: queueRepo, executor: executor);
  final connectivityMonitor = ConnectivityMonitor();
  final coordinator = SyncCoordinator(
    queueProcessor: queueProcessor,
    connectivityMonitor: connectivityMonitor,
  );

  await coordinator.recoverDeadLetters();

  final dlRes = await db.query('sync_queue', where: "queue_uuid IN ('dl1', 'dl2')");
  for (final row in dlRes) {
    print('Row ${row['queue_uuid']} -> status=${row['status']}, attempt_count=${row['attempt_count']}');
  }

  // Phase 5 - Queue Metrics
  print('\\n--- Validation 5 - Metrics ---');
  final pending = await queueRepo.getPendingCount();
  final deadLetters = await queueRepo.getDeadLetterCount();
  final oldestAge = await queueRepo.getOldestPendingAge();
  
  print('getPendingCount() = $pending');
  print('getDeadLetterCount() = $deadLetters');
  print('getOldestPendingAge() = $oldestAge');
}
