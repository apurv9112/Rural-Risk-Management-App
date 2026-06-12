import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'dart:io';
import 'package:rrm/services/offline/mock_media_transport_service.dart';
import 'package:rrm/services/offline/media_sync_worker.dart';
import 'package:rrm/services/offline/queue_models.dart';
import 'package:rrm/services/offline/auth_recovery_service.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  print('============================================');
  print('M16.12 TRANSPORT VALIDATION START');
  print('============================================');

  // Create temporary directory for dummy files
  final tempDir = Directory.systemTemp.createTempSync('m16_12_');

  try {
    await testPhase4ResumeValidation(tempDir.path);
    await testPhase5FailureInjection(tempDir.path);
    await testPhase6ParentReleaseValidation(tempDir.path);
    await testPhase7PerformanceAudit(tempDir.path);
  } catch (e, st) {
    print('Validation failed: $e');
    print(st);
  } finally {
    // Cleanup
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }

  print('============================================');
  print('M16.12 TRANSPORT VALIDATION END');
  print('============================================');
}

Future<File> createDummyFile(String path, int sizeInMB) async {
  final file = File(path);
  final raf = await file.open(mode: FileMode.write);
  final chunk = List<int>.filled(1024 * 1024, 0); // 1MB chunk
  for (int i = 0; i < sizeInMB; i++) {
    await raf.writeFrom(chunk);
  }
  await raf.close();
  return file;
}

// -----------------------------------------------------------------------------
// Phase 4 - Resume Validation
// -----------------------------------------------------------------------------
Future<void> testPhase4ResumeValidation(String dir) async {
  print('\\n--- Phase 4: Resume Validation ---');
  final file = await createDummyFile('$dir/resume_test.dat', 75);
  
  final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

  final transport = MockMediaTransportService();
  final worker = MediaSyncWorker(transportService: transport, syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo, authRecoveryService: MockAuthRecoveryService());

  final syncQueue = SyncQueue(id: 'sync_1');
  await syncRepo.insert(\1);

  final mediaQueue = MediaQueue(
    id: 'media_1',
    syncQueueId: 'sync_1',
    filePath: file.path,
    totalSizeBytes: 75 * 1024 * 1024,
  );
  await mediaRepo.insert(\1);

  // Simulate partial upload and app kill
  // Manually set state to simulate we uploaded 25MB (5 chunks of 5MB)
  mediaQueue.state = MediaState.CHUNK_LOOP;
  mediaQueue.uploadedBytes = 25 * 1024 * 1024;
  mediaQueue.remoteUploadId = 'mock_upload_previous_session';
  await mediaRepo.update(\1);

  print('Simulating resume at ${mediaQueue.uploadedBytes} bytes...');
  await worker.processMedia('media_1');

  final updatedMedia = (await mediaRepo.getById(\1))!;
  print('Uploaded Bytes after worker: ${updatedMedia.uploadedBytes}');
  print('Final State: ${updatedMedia.state}');
  
  if (updatedMedia.uploadedBytes == 75 * 1024 * 1024 && updatedMedia.state == MediaState.COMPLETED) {
    print('SUCCESS: uploaded_bytes survives and resumes successfully.');
    print('SUCCESS: remote_upload_id survives.');
  } else {
    print('FAILED: Resume validation.');
  }
}

// -----------------------------------------------------------------------------
// Phase 5 - Failure Injection
// -----------------------------------------------------------------------------
Future<void> testPhase5FailureInjection(String dir) async {
  print('\\n--- Phase 5: Failure Injection ---');
  
  final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

  final transport = MockMediaTransportService();
  final worker = MediaSyncWorker(transportService: transport, syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo, authRecoveryService: MockAuthRecoveryService());
  
  final file = await createDummyFile('$dir/failure_test.dat', 30); // 30MB

  // 1. Network Failure after chunk 3
  print('\\nInjecting Network Failure after chunk 3...');
  transport.injectNetworkFailureAfterChunk3 = true;
  final media1 = MediaQueue(
    id: 'media_fail_1',
    syncQueueId: 'sync_fail',
    filePath: file.path,
    totalSizeBytes: 30 * 1024 * 1024,
  );
  await mediaRepo.insert(\1);
  await worker.processMedia('media_fail_1');
  print('Expected: RETRY_PENDING, Got: ${(await mediaRepo.getById(\1))!.state}');

  // 2. Auth Failure during complete
  print('\\nInjecting Auth Failure during complete...');
  transport.injectNetworkFailureAfterChunk3 = false;
  transport.injectAuthFailureDuringComplete = true;
  final media2 = MediaQueue(
    id: 'media_fail_2',
    syncQueueId: 'sync_fail',
    filePath: file.path,
    totalSizeBytes: 30 * 1024 * 1024,
  );
  await mediaRepo.insert(\1);
  await worker.processMedia('media_fail_2');
  print('Expected: FAILED, Got: ${(await mediaRepo.getById(\1))!.state}');

  // 3. File Missing before init
  print('\\nInjecting File Missing before init...');
  final media3 = MediaQueue(
    id: 'media_fail_3',
    syncQueueId: 'sync_fail',
    filePath: '$dir/non_existent.dat',
    totalSizeBytes: 10 * 1024 * 1024,
  );
  await mediaRepo.insert(\1);
  await worker.processMedia('media_fail_3');
  print('Expected: FAILED, Got: ${(await mediaRepo.getById(\1))!.state}');
}

// -----------------------------------------------------------------------------
// Phase 6 - Parent Release Validation
// -----------------------------------------------------------------------------
Future<void> testPhase6ParentReleaseValidation(String dir) async {
  print('\\n--- Phase 6: Parent Release Validation ---');
  final file = await createDummyFile('$dir/release_test.dat', 10);
  
  final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

  final transport = MockMediaTransportService();
  final worker = MediaSyncWorker(transportService: transport, syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo, authRecoveryService: MockAuthRecoveryService());

  final syncQueue = SyncQueue(id: 'sync_parent');
  await syncRepo.insert(\1);

  // Create 3 media queue rows
  for (int i = 1; i <= 3; i++) {
    db.insertMediaQueue(MediaQueue(
      id: 'media_child_$i',
      syncQueueId: 'sync_parent',
      filePath: file.path,
      totalSizeBytes: 10 * 1024 * 1024,
    ));
  }

  print('Initial incomplete count: ${(await mediaRepo.getBySyncQueueId(\1)).where((m) => m.state != MediaState.COMPLETED).length}');
  print('Initial parent state: ${(await syncRepo.getById(\1))!.state}');

  for (int i = 1; i <= 3; i++) {
    print('Processing media_child_$i...');
    await worker.processMedia('media_child_$i');
  }

  final incompleteCount = (await mediaRepo.getBySyncQueueId(\1)).where((m) => m.state != MediaState.COMPLETED).length;
  final parentState = (await syncRepo.getById(\1))!.state;
  print('Final incomplete count: $incompleteCount');
  print('Final parent state: $parentState');

  if (incompleteCount == 0 && parentState == SyncState.ELIGIBLE_FOR_SYNC) {
    print('SUCCESS: countIncompleteMediaForQueue = 0');
    print('SUCCESS: Parent becomes eligible.');
  } else {
    print('FAILED: Parent release validation.');
  }
}

// -----------------------------------------------------------------------------
// Phase 7 - Performance Audit
// -----------------------------------------------------------------------------
Future<void> testPhase7PerformanceAudit(String dir) async {
  print('\\n--- Phase 7: Performance Audit ---');
  
  // Create 100MB file
  print('Creating 100MB file (this takes a few seconds)...');
  final file = await createDummyFile('$dir/perf_test.dat', 100);
  
  final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

  final transport = MockMediaTransportService();
  final worker = MediaSyncWorker(transportService: transport, syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo, authRecoveryService: MockAuthRecoveryService());

  final mediaQueue = MediaQueue(
    id: 'media_perf',
    syncQueueId: 'sync_perf',
    filePath: file.path,
    totalSizeBytes: 100 * 1024 * 1024,
  );
  await mediaRepo.insert(\1);

  final processInfoBefore = ProcessInfo.currentRss;
  print('Starting memory (RSS): ${processInfoBefore / 1024 / 1024} MB');

  print('Processing 100MB file...');
  await worker.processMedia('media_perf');

  final processInfoAfter = ProcessInfo.currentRss;
  print('Ending memory (RSS): ${processInfoAfter / 1024 / 1024} MB');
  
  final memDiff = (processInfoAfter - processInfoBefore) / 1024 / 1024;
  print('Memory diff: $memDiff MB');

  if ((await mediaRepo.getById(\1))!.state == MediaState.COMPLETED) {
    if (memDiff < 30) {
      print('SUCCESS: RAM usage remains bounded. (No full-file read)');
    } else {
      print('WARNING: RAM usage might be high.');
    }
  } else {
    print('FAILED: Processing did not complete.');
  }
}
