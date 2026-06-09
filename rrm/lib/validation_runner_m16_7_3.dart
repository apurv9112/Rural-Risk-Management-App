import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import 'core/database/app_database.dart';
import 'data/repositories/media_queue_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("========================================");
  print("STARTING M16.7.3 REPLACE REMEDIATION VALIDATION");
  print("========================================");

  final db = await AppDatabase.instance.database;
  final mediaRepo = MediaQueueRepository(db: db);
  final uuid = const Uuid();

  // Create a parent queue to satisfy FK
  final qUuid = uuid.v4();
  await db.insert('sync_queue', {
    'queue_uuid': qUuid,
    'idempotency_key': 'idem_${qUuid}',
    'entity_type': 'test',
    'status': 'PENDING',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });

  final mUuid = uuid.v4();
  
  print("--- STEP 1: Insert Media ---");
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

  print("--- STEP 2: Update Progress ---");
  await mediaRepo.updateUploadProgress(mUuid, 'upload_123', 55000000);

  final snapshot1 = await db.query('media_queue', where: 'media_uuid = ?', whereArgs: [mUuid]);
  print("BEFORE DRAFT SAVE: bytes = ${snapshot1.first['uploaded_bytes']}, upload_id = ${snapshot1.first['remote_upload_id']}");

  print("--- STEP 3: Simulate Draft Save ---");
  // Using createMedia (which has IGNORE now)
  await mediaRepo.createMedia({
    'media_uuid': mUuid,
    'queue_uuid': qUuid,
    'workflow_type': 'test',
    'local_file_path': '/test_renamed',
    'file_name': 'test_renamed.jpg',
    'file_size': 100,
    'media_key_name': 'testKey',
    'created_at': DateTime.now().millisecondsSinceEpoch,
    'updated_at': DateTime.now().millisecondsSinceEpoch,
  });

  // Attempt to update metadata via the safe metadata updater
  await mediaRepo.updateMediaMetadata(mUuid, {
    'file_name': 'test_updated_metadata.jpg',
    'uploaded_bytes': 0, // This should be ignored by the safe remover
    'remote_upload_id': 'hacked_id' // This should be ignored
  });

  print("--- STEP 4: Verification ---");
  final snapshot2 = await db.query('media_queue', where: 'media_uuid = ?', whereArgs: [mUuid]);
  
  print("AFTER DRAFT SAVE: bytes = ${snapshot2.first['uploaded_bytes']}, upload_id = ${snapshot2.first['remote_upload_id']}, file_name = ${snapshot2.first['file_name']}");

  if (snapshot2.first['uploaded_bytes'] == 55000000 && snapshot2.first['remote_upload_id'] == 'upload_123') {
    print("PASS: Progress successfully survived duplicate insert/update.");
  } else {
    print("FAIL: Progress was lost!");
  }

  if (snapshot2.first['file_name'] == 'test_updated_metadata.jpg') {
    print("PASS: Safe metadata successfully updated.");
  } else {
    print("FAIL: Safe metadata was not applied.");
  }

  // Cleanup
  await db.delete('sync_queue', where: 'queue_uuid = ?', whereArgs: [qUuid]);

  print("========================================");
  print("M16.7.3 VALIDATION COMPLETE");
  print("========================================");
}
