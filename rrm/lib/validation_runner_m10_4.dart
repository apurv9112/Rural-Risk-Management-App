import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rrm/data/repositories/media_repository.dart';
import 'package:rrm/data/repositories/draft_repository.dart';
import 'package:rrm/data/repositories/conflict_repository.dart';
import 'package:rrm/data/models/media_metadata_model.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/home/home_controller.dart';
import 'package:rrm/data/repositories/lead_repository.dart';

import 'package:get_storage/get_storage.dart';
import 'package:rrm/controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(AppController());
  Get.put(DraftRepository());
  Get.put(LeadRepository());
  Get.put(HomeController());

  await runM10_4Audit();
  exit(0);
}

Future<void> runM10_4Audit() async {
  print('=============================================');
  print('=== M10.4 VALIDATION AUDIT STARTING ===');
  print('=============================================');

  final db = await AppDatabase.instance.database;

  // Clean state for clean validation
  await db.delete('leads');
  await db.delete('cattle');
  await db.delete('media_metadata');
  await db.delete('draft_progress');
  await db.delete('sync_queue');
  await db.delete('conflict_log');

  // --- Validation 1: Media Persistence Repair ---
  print('\n--- Validation 1 – Media Persistence Location Audit ---');
  final mediaRepo = MediaRepository();
  final cacheDir = await getTemporaryDirectory();
  
  List<String> permanentPaths = [];
  bool allPathsInRRM = true;

  // Insert dummy lead and cattle for foreign key constraints
  final dummyLeadUuid = const Uuid().v4();
  final dummyCattleUuid = const Uuid().v4();
  await db.insert('leads', {'local_uuid': dummyLeadUuid, 'sync_status': 'DRAFT'});
  await db.insert('cattle', {'local_uuid': dummyCattleUuid, 'lead_uuid': dummyLeadUuid});

  for (int i = 0; i < 3; i++) {
    final tempFile = File('${cacheDir.path}/test_img_$i.jpg');
    await tempFile.writeAsString('fake_image_data_$i');
    
    final mediaUuid = const Uuid().v4();
    final metadata = MediaMetadataModel(
      localUuid: mediaUuid,
      cattleUuid: dummyCattleUuid,
      leadUuid: dummyLeadUuid,
      captureType: 'test',
      mediaType: 'image',
      syncStatus: 'DRAFT',
    );

    await mediaRepo.saveDraftMedia(
      tempFile: tempFile,
      workflowType: 'test',
      targetFileName: mediaUuid,
      metadata: metadata,
    );

    final row = await db.query('media_metadata', where: 'local_uuid = ?', whereArgs: [mediaUuid]);
    final path = row.first['absolute_local_path'] as String;
    
    print('absolute_local_path: $path');
    print('existsSync(): ${File(path).existsSync()}');
    print('file size: ${await File(path).length()} bytes');
    
    if (path.contains('cache')) {
      allPathsInRRM = false;
    }
  }
  print('Expected All files under RRM/media/: $allPathsInRRM');

  // --- Validation 2: Draft Deletion Repair ---
  print('\n--- Validation 2 – Draft Deletion Repair ---');
  final draftRepo = DraftRepository();
  final v2LeadUuid = const Uuid().v4();
  
  await db.insert('leads', {'local_uuid': v2LeadUuid, 'sync_status': 'DRAFT'});
  await db.insert('cattle', {'local_uuid': const Uuid().v4(), 'lead_uuid': v2LeadUuid});
  await db.insert('draft_progress', {'entity_uuid': v2LeadUuid, 'workflow_type': 'Tagging', 'current_step': 1, 'last_screen_route': '/', 'completion_percentage': 50, 'updated_at': DateTime.now().toIso8601String()});
  await db.insert('sync_queue', {'queue_uuid': const Uuid().v4(), 'entity_uuid': v2LeadUuid, 'status': 'PENDING', 'idempotency_key': const Uuid().v4()});

  final tempFile2 = File('${cacheDir.path}/test_del.jpg');
  await tempFile2.writeAsString('delete_me');
  final v2MediaUuid = const Uuid().v4();
  await mediaRepo.saveDraftMedia(
    tempFile: tempFile2,
    workflowType: 'test',
    targetFileName: v2MediaUuid,
    metadata: MediaMetadataModel(
      localUuid: v2MediaUuid,
      cattleUuid: null,
      leadUuid: v2LeadUuid,
      captureType: 'test',
      mediaType: 'image',
      syncStatus: 'DRAFT',
    ),
  );

  final v2MediaRowBefore = await db.query('media_metadata', where: 'lead_uuid = ?', whereArgs: [v2LeadUuid]);
  final v2Path = v2MediaRowBefore.first['absolute_local_path'] as String;

  print("Before delete:");
  print("lead count: ${Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM leads WHERE local_uuid = '$v2LeadUuid'"))}");
  print("cattle count: ${Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM cattle WHERE lead_uuid = '$v2LeadUuid'"))}");
  print("media count: ${v2MediaRowBefore.length}");
  print("file exists: ${File(v2Path).existsSync()}");

  await draftRepo.deleteDraft(v2LeadUuid);

  print("After delete:");
  print("lead count: ${Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM leads WHERE local_uuid = '$v2LeadUuid'"))}");
  print("cattle count: ${Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM cattle WHERE lead_uuid = '$v2LeadUuid'"))}");
  print("media count: ${Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM media_metadata WHERE lead_uuid = '$v2LeadUuid'"))}");
  print("file exists: ${File(v2Path).existsSync()}");

  // --- Validation 3: Conflict Engine Completion ---
  print('\n--- Validation 3 – Conflict Engine Completion ---');
  final conflictRepo = ConflictRepository();
  final v3LeadUuid = const Uuid().v4();
  await db.insert('leads', {'local_uuid': v3LeadUuid, 'sync_status': 'DRAFT'});
  await db.insert('sync_queue', {'queue_uuid': const Uuid().v4(), 'entity_uuid': v3LeadUuid, 'status': 'PENDING', 'idempotency_key': const Uuid().v4()});

  await conflictRepo.createConflict(
    entityType: 'leads',
    entityUuid: v3LeadUuid,
    localPayloadJson: '{"farmer": "LocalName"}',
    serverPayloadJson: '{"farmer": "ServerName"}',
  );

  final conflictRowBefore = await db.query('conflict_log', where: 'entity_uuid = ? AND resolved_at IS NULL', whereArgs: [v3LeadUuid]);
  print('SQLite row before: $conflictRowBefore');
  final conflictUuid = conflictRowBefore.first['conflict_uuid'] as String;

  await conflictRepo.keepLocal(conflictUuid, v3LeadUuid);
  final leadsRowLocal = await db.query('leads', where: 'local_uuid = ?', whereArgs: [v3LeadUuid]);
  final queueRowLocal = await db.query('sync_queue', where: 'entity_uuid = ?', whereArgs: [v3LeadUuid]);
  print('Keep Local Result:');
  print("leads.sync_status: ${leadsRowLocal.first['sync_status']}");
  print("sync_queue.status: ${queueRowLocal.first['status']}");

  // Reset to conflict
  await conflictRepo.createConflict(
    entityType: 'leads',
    entityUuid: v3LeadUuid,
    localPayloadJson: '{"farmer": "LocalName"}',
    serverPayloadJson: '{"farmer": "ServerName"}',
  );
  final conflictRowBefore2 = await db.query('conflict_log', where: 'entity_uuid = ? AND resolved_at IS NULL', whereArgs: [v3LeadUuid]);
  final conflictUuid2 = conflictRowBefore2.first['conflict_uuid'] as String;

  await conflictRepo.keepServer(conflictUuid2, v3LeadUuid);
  final leadsRowServer = await db.query('leads', where: 'local_uuid = ?', whereArgs: [v3LeadUuid]);
  final queueRowServer = await db.query('sync_queue', where: 'entity_uuid = ?', whereArgs: [v3LeadUuid]);
  print('Keep Server Result:');
  print("leads.sync_status: ${leadsRowServer.first['sync_status']}");
  print("sync_queue.status: ${queueRowServer.first['status']}");


  // --- Validation 4: Badge Counter Repair ---
  print('\n--- Validation 4 – Badge Counter Repair ---');
  await db.delete('leads');
  await db.delete('sync_queue');

  // 2 Drafts
  await db.insert('leads', {'local_uuid': const Uuid().v4(), 'sync_status': 'DRAFT'});
  await db.insert('leads', {'local_uuid': const Uuid().v4(), 'sync_status': 'DRAFT'});
  
  // 1 Pending
  await db.insert('sync_queue', {'queue_uuid': const Uuid().v4(), 'entity_uuid': 'q1', 'status': 'PENDING', 'idempotency_key': const Uuid().v4()});
  
  // 1 Dead Letter
  await db.insert('sync_queue', {'queue_uuid': const Uuid().v4(), 'entity_uuid': 'q2', 'status': 'DEAD_LETTER', 'idempotency_key': const Uuid().v4()});
  
  // 1 Conflict
  await db.insert('sync_queue', {'queue_uuid': const Uuid().v4(), 'entity_uuid': 'q3', 'status': 'CONFLICT', 'idempotency_key': const Uuid().v4()});

  print('Individual Counts:');
  print('Drafts: 2');
  print('Pending: 1');
  print('Dead Letter: 1');
  print('Conflict: 1');

  final homeController = Get.find<HomeController>();
  await homeController.updateDraftCount();

  print('Displayed badge count: ${homeController.draftCount.value}');

  print('=============================================');
  print('=== M10.4 VALIDATION AUDIT COMPLETED ===');
  print('=============================================');
}
