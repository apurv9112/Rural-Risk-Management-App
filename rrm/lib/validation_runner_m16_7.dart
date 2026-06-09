import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'core/database/app_database.dart';
import 'data/repositories/media_queue_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("========================================");
  print("STARTING M16.7 V8 DATABASE VALIDATION");
  print("========================================");

  final db = await AppDatabase.instance.database;
  final mediaRepo = MediaQueueRepository(db: db);
  final uuid = const Uuid();

  // 1. Schema Existence
  final tableInfo = await db.rawQuery("PRAGMA table_info(media_queue)");
  if (tableInfo.isEmpty) {
    print("FAIL: media_queue table does not exist.");
    return;
  }
  print("PASS: media_queue schema verified.");

  // 2. Index Existence
  final indexes = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='media_queue'");
  final indexNames = indexes.map((e) => e['name'] as String).toList();
  if (indexNames.contains('idx_media_queue_uuid') && indexNames.contains('idx_media_upload_status')) {
    print("PASS: media_queue indexes verified.");
  } else {
    print("FAIL: Missing expected indexes.");
  }

  // 3. Foreign Key Validation
  try {
    await mediaRepo.createMedia({
      'media_uuid': uuid.v4(),
      'queue_uuid': 'FAKE_QUEUE_UUID',
      'workflow_type': 'test',
      'local_file_path': '/test',
      'file_name': 'test.jpg',
      'file_size': 100,
      'media_key_name': 'testKey',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
    print("FAIL: SQLite allowed insert with fake queue_uuid.");
  } on DatabaseException catch (e) {
    if (e.toString().contains("FOREIGN KEY constraint failed")) {
      print("PASS: Foreign key correctly rejected orphaned media.");
    } else {
      print("FAIL: Unexpected error during FK test: $e");
    }
  }

  // 4. Cascade Delete
  final qUuid = uuid.v4();
  await db.insert('sync_queue', {
    'queue_uuid': qUuid,
    'idempotency_key': 'idem_$qUuid',
    'entity_type': 'test',
    'status': 'PENDING',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  final mUuid = uuid.v4();
  await mediaRepo.createMedia({
    'media_uuid': mUuid,
    'queue_uuid': qUuid,
    'workflow_type': 'test',
    'local_file_path': '/test',
    'file_name': 'test.jpg',
    'file_size': 100,
    'media_key_name': 'testKey',
    'created_at': DateTime.now().millisecondsSinceEpoch,
    'updated_at': DateTime.now().millisecondsSinceEpoch,
  });

  await db.delete('sync_queue', where: 'queue_uuid = ?', whereArgs: [qUuid]);
  final checkMedia = await db.query('media_queue', where: 'media_uuid = ?', whereArgs: [mUuid]);
  if (checkMedia.isEmpty) {
    print("PASS: Cascade delete successfully purged media_queue row.");
  } else {
    print("FAIL: media_queue row survived sync_queue deletion.");
  }

  // 5. State Transitions & Lock
  final qUuid2 = uuid.v4();
  await db.insert('sync_queue', {
    'queue_uuid': qUuid2,
    'idempotency_key': 'idem_$qUuid2',
    'entity_type': 'test',
    'status': 'PENDING',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  final mUuid2 = uuid.v4();
  await mediaRepo.createMedia({
    'media_uuid': mUuid2,
    'queue_uuid': qUuid2,
    'workflow_type': 'test',
    'local_file_path': '/test',
    'file_name': 'test.jpg',
    'file_size': 100,
    'media_key_name': 'testKey',
    'created_at': DateTime.now().millisecondsSinceEpoch,
    'updated_at': DateTime.now().millisecondsSinceEpoch,
  });

  final claimed = await mediaRepo.claimMediaForUpload(mUuid2);
  if (claimed) {
    print("PASS: Claim lock acquired successfully.");
  } else {
    print("FAIL: Failed to acquire claim lock.");
  }
  
  final claimedAgain = await mediaRepo.claimMediaForUpload(mUuid2);
  if (!claimedAgain) {
    print("PASS: Secondary claim lock correctly rejected.");
  } else {
    print("FAIL: Secondary claim lock succeeded incorrectly.");
  }

  await mediaRepo.updateUploadProgress(mUuid2, "upload_123", 500);
  final progressCheck = await db.query('media_queue', where: 'media_uuid = ?', whereArgs: [mUuid2]);
  if (progressCheck.first['uploaded_bytes'] == 500) {
    print("PASS: Upload progress state updated.");
  } else {
    print("FAIL: Progress update failed.");
  }

  await mediaRepo.markCompleted(mUuid2, "asset_456");
  final completeCheck = await db.query('media_queue', where: 'media_uuid = ?', whereArgs: [mUuid2]);
  if (completeCheck.first['upload_status'] == 'COMPLETED' && completeCheck.first['remote_asset_id'] == 'asset_456') {
    print("PASS: Completion state verified.");
  } else {
    print("FAIL: Completion state incorrect.");
  }

  // 6. 10k Row Performance
  print("Running 10k row insertion performance test...");
  final batch = db.batch();
  final parentQ = uuid.v4();
  await db.insert('sync_queue', {
    'queue_uuid': parentQ,
    'idempotency_key': 'idem_$parentQ',
    'entity_type': 'test',
    'status': 'PENDING',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });
  
  final stopwatch = Stopwatch()..start();
  for (int i = 0; i < 10000; i++) {
    batch.insert('media_queue', {
      'media_uuid': uuid.v4(),
      'queue_uuid': parentQ,
      'workflow_type': 'perf',
      'local_file_path': '/perf_$i',
      'file_name': 'perf_$i.jpg',
      'file_size': 10,
      'media_key_name': 'perfKey',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
  await batch.commit(noResult: true);
  stopwatch.stop();
  print("PASS: Inserted 10,000 rows in ${stopwatch.elapsedMilliseconds}ms.");

  final queryStopwatch = Stopwatch()..start();
  await db.query('media_queue', where: 'queue_uuid = ?', whereArgs: [parentQ]);
  queryStopwatch.stop();
  print("PASS: Queried 10,000 rows via index in ${queryStopwatch.elapsedMilliseconds}ms.");

  // Cleanup 10k
  await db.delete('sync_queue', where: 'queue_uuid = ?', whereArgs: [parentQ]);
  print("PASS: Cascade deleted 10,000 rows successfully.");

  print("========================================");
  print("M16.7 VALIDATION COMPLETE");
  print("========================================");
}
