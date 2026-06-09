import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'core/database/app_database.dart';
import 'data/repositories/media_queue_repository.dart';
import 'core/sync/media_sync_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("========================================");
  print("STARTING M16.9 MEDIA SYNC WORKER VALIDATION");
  print("========================================");

  final db = await AppDatabase.instance.database;
  final mediaRepo = MediaQueueRepository(db: db);
  final worker = MediaSyncWorker(repository: mediaRepo);
  final uuid = const Uuid();

  // Clear table for clean state
  await db.delete('media_queue');
  await db.delete('sync_queue');

  // Helper
  Future<String> insertMedia(String queueUuid, {DateTime? createdAt}) async {
    final mUuid = uuid.v4();
    await mediaRepo.createMedia({
      'media_uuid': mUuid,
      'queue_uuid': queueUuid,
      'workflow_type': 'test',
      'local_file_path': '/test.jpg',
      'file_name': 'test.jpg',
      'file_size': 100,
      'media_key_name': 'testKey',
      'created_at': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
    return mUuid;
  }

  print("--- Test 1: Claim Lock Exclusivity ---");
  final q1 = uuid.v4();
  await db.insert('sync_queue', {
    'queue_uuid': q1, 'idempotency_key': 'i1', 'entity_type': 't', 'status': 'PENDING',
    'created_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String()
  });
  final m1 = await insertMedia(q1);

  final claim1 = await mediaRepo.claimMediaForUpload(m1);
  final claim2 = await mediaRepo.claimMediaForUpload(m1);
  
  if (claim1) print("PASS: First worker acquired lock.");
  else print("FAIL: First worker failed lock.");
  
  if (!claim2) print("PASS: Second worker rejected.");
  else print("FAIL: Second worker incorrectly acquired lock.");

  print("--- Test 2: Sequential Processing ---");
  await db.delete('media_queue');
  final m2_old = await insertMedia(q1, createdAt: DateTime.now().subtract(const Duration(minutes: 5)));
  final m2_new = await insertMedia(q1, createdAt: DateTime.now());
  
  final next = await mediaRepo.getNextPendingMedia();
  if (next != null && next['media_uuid'] == m2_old) {
    print("PASS: Records processed in created_at order.");
  } else {
    print("FAIL: Sequential ordering violated.");
  }

  print("--- Test 3: Retry Transition ---");
  await db.delete('media_queue');
  final m3 = await insertMedia(q1);
  worker.testInjectTimeout = true;
  await worker.processQueue(singleRun: true); // Only run one iteration so it doesn't exhaust 5 retries instantly
  worker.testInjectTimeout = false;
  
  final m3State = await db.query('media_queue', where: 'media_uuid = ?', whereArgs: [m3]);
  if (m3State.first['upload_status'] == 'RETRY_PENDING' && m3State.first['upload_attempts'] == 1) {
    print("PASS: PENDING -> UPLOADING -> RETRY_PENDING.");
  } else {
    print("FAIL: Retry transition incorrect: ${m3State.first['upload_status']}");
  }

  print("--- Test 4: Completion Transition ---");
  await db.delete('media_queue');
  final m4 = await insertMedia(q1);
  await worker.processQueue();
  final m4State = await db.query('media_queue', where: 'media_uuid = ?', whereArgs: [m4]);
  if (m4State.first['upload_status'] == 'COMPLETED' && m4State.first['remote_asset_id'] != null) {
    print("PASS: PENDING -> UPLOADING -> COMPLETED.");
  } else {
    print("FAIL: Completion transition incorrect.");
  }

  print("--- Test 5: Stale Lock Recovery ---");
  await db.delete('media_queue');
  final m5 = await insertMedia(q1);
  await db.update('media_queue', 
    {'upload_status': 'UPLOADING', 'updated_at': DateTime.now().subtract(const Duration(minutes: 31)).toIso8601String()},
    where: 'media_uuid = ?', whereArgs: [m5]
  );
  await worker.initialize(); // Triggers recovery
  final m5State = await db.query('media_queue', where: 'media_uuid = ?', whereArgs: [m5]);
  if (m5State.first['upload_status'] == 'RETRY_PENDING') {
    print("PASS: UPLOADING (31 mins old) -> RETRY_PENDING.");
  } else {
    print("FAIL: Stale lock not recovered.");
  }

  print("--- Test 6: Parent Gating ---");
  await db.delete('media_queue');
  final q6 = uuid.v4();
  await db.insert('sync_queue', {
    'queue_uuid': q6, 'idempotency_key': 'i6', 'entity_type': 't', 'status': 'PENDING',
    'created_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String()
  });
  
  await insertMedia(q6); // PENDING
  await insertMedia(q6); // PENDING
  
  var count = await mediaRepo.countIncompleteMediaForQueue(q6);
  if (count == 2) print("PASS: Parent blocked when child incomplete. (count=$count)");
  else print("FAIL: Parent block logic failed.");

  await worker.processQueue(); // Completes both
  count = await mediaRepo.countIncompleteMediaForQueue(q6);
  if (count == 0) print("PASS: Parent released when all children completed. (count=$count)");
  else print("FAIL: Parent release logic failed.");

  print("--- Test 7: 10,000 Row Polling Audit ---");
  await db.delete('media_queue');
  print("Inserting 10,000 rows...");
  final batch = db.batch();
  for(int i = 0; i < 10000; i++) {
     batch.insert('media_queue', {
      'media_uuid': uuid.v4(),
      'queue_uuid': q1,
      'workflow_type': 'test',
      'local_file_path': '/test.jpg',
      'file_name': 'test.jpg',
      'file_size': 100,
      'media_key_name': 'testKey',
      'upload_status': i == 9999 ? 'PENDING' : 'COMPLETED',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
  await batch.commit(noResult: true);
  
  final sw = Stopwatch()..start();
  await mediaRepo.getNextPendingMedia();
  sw.stop();
  if (sw.elapsedMilliseconds < 100) {
    print("PASS: < 100ms indexed retrieval (${sw.elapsedMilliseconds}ms).");
  } else {
    print("FAIL: Retrieval took ${sw.elapsedMilliseconds}ms.");
  }

  print("========================================");
  print("M16.9 VALIDATION COMPLETE");
  print("========================================");
}
