import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:rrm/services/offline/mock_media_transport_service.dart';
import 'package:rrm/services/offline/auth_recovery_service.dart';
import 'package:rrm/services/offline/media_sync_worker.dart';
import 'package:rrm/services/offline/queue_models.dart';
import 'package:rrm/services/offline/sync_coordinator.dart';
import 'package:rrm/services/offline/queue_processor.dart';
import 'package:rrm/services/offline/payload_assembly_service.dart';
import 'package:rrm/services/offline/sync_status_service.dart';
import 'package:rrm/services/offline/queue_statistics_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() {
    GetIt.I.allowReassignment = true;
    final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

    GetIt.I.registerSingleton<MockDatabase>(db);
    GetIt.I.registerSingleton<SyncStatusService>(SyncStatusService());
    GetIt.I.registerSingleton<AuthRecoveryService>(MockAuthRecoveryService());
    
    final transport = MockMediaTransportService();
    GetIt.I.registerSingleton<MockMediaTransportService>(transport);
    
    final worker = MediaSyncWorker(
      transportService: transport,
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      authRecoveryService: GetIt.I<AuthRecoveryService>(),
    );
    GetIt.I.registerSingleton<MediaSyncWorker>(worker);
    
    GetIt.I.registerSingleton<QueueProcessor>(QueueProcessor(
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      assemblyService: PayloadAssemblyService(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo),
    ));
    GetIt.I.registerSingleton<SyncCoordinator>(SyncCoordinator(
      mediaSyncWorker: worker,
      queueProcessor: GetIt.I<QueueProcessor>(),
      syncStatusService: GetIt.I<SyncStatusService>(),
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
    ));
    GetIt.I.registerSingleton<QueueStatisticsService>(QueueStatisticsService(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo));
  });

  test('Test A, B, G: 401 Mid Upload & State Preservation', () async {
    final db = GetIt.I<MockDatabase>();
    final worker = GetIt.I<MediaSyncWorker>();
    final transport = GetIt.I<MockMediaTransportService>();
    
    // Configure mock: fail at chunk 2 with 401
    transport.inject401MidUpload = true;
    transport.inject401AtChunk = 2; // Chunk index 2
    
    File('auth1.jpg').writeAsBytesSync(List.filled(20 * 1024 * 1024, 0)); // 20MB file
    
    db.insertSyncQueue(SyncQueue(id: 'sync_1', state: SyncState.PENDING));
    db.insertMediaQueue(MediaQueue(
      id: 'media_1',
      syncQueueId: 'sync_1',
      filePath: 'auth1.jpg',
      totalSizeBytes: 20 * 1024 * 1024,
      state: MediaState.PENDING,
    ));
    
    await worker.processMedia('media_1');
    
    // State Preservation check:
    // It should have caught the 401, called AuthRecoveryService (which succeeds by default), 
    // retried the chunk, and successfully completed the upload.
    expect((await mediaRepo.getById(\1))!.state, MediaState.COMPLETED);
    expect((await mediaRepo.getById(\1))!.uploadedBytes, 20 * 1024 * 1024);
  });
  
  test('Test C: Refresh Failure', () async {
    final db = GetIt.I<MockDatabase>();
    final worker = GetIt.I<MediaSyncWorker>();
    final transport = GetIt.I<MockMediaTransportService>();
    final auth = GetIt.I<AuthRecoveryService>() as MockAuthRecoveryService;
    
    transport.inject401MidUpload = true;
    transport.inject401AtChunk = 2;
    auth.failRefresh = true; // Inject refresh failure
    
    File('auth2.jpg').writeAsBytesSync(List.filled(20 * 1024 * 1024, 0));
    
    db.insertSyncQueue(SyncQueue(id: 'sync_2', state: SyncState.PENDING));
    db.insertMediaQueue(MediaQueue(
      id: 'media_2',
      syncQueueId: 'sync_2',
      filePath: 'auth2.jpg',
      totalSizeBytes: 20 * 1024 * 1024,
      state: MediaState.PENDING,
    ));
    
    await worker.processMedia('media_2');
    
    // Because refresh failed, it should be marked as FAILED permanently.
    expect((await mediaRepo.getById(\1))!.state, MediaState.FAILED);
    expect((await mediaRepo.getById(\1))!.uploadedBytes, 2 * 5 * 1024 * 1024); // Reached 10MB before failing on chunk 2
  });

  test('Test D: 403 Forbidden Handling', () async {
    final db = GetIt.I<MockDatabase>();
    final worker = GetIt.I<MediaSyncWorker>();
    final transport = GetIt.I<MockMediaTransportService>();
    
    transport.inject403AtChunk = true; // Fails at chunk 2
    
    File('auth3.jpg').writeAsBytesSync(List.filled(20 * 1024 * 1024, 0));
    
    db.insertSyncQueue(SyncQueue(id: 'sync_3', state: SyncState.PENDING));
    db.insertMediaQueue(MediaQueue(
      id: 'media_3',
      syncQueueId: 'sync_3',
      filePath: 'auth3.jpg',
      totalSizeBytes: 20 * 1024 * 1024,
      state: MediaState.PENDING,
    ));
    
    await worker.processMedia('media_3');
    
    expect((await mediaRepo.getById(\1))!.state, MediaState.FAILED);
    expect((await mediaRepo.getById(\1))!.uploadedBytes, 2 * 5 * 1024 * 1024);
  });
  
  test('Test E: 429 Rate Limit Handling', () async {
    final db = GetIt.I<MockDatabase>();
    final worker = GetIt.I<MediaSyncWorker>();
    final transport = GetIt.I<MockMediaTransportService>();
    
    transport.inject429AtChunk = true; // Fails at chunk 2
    
    File('auth4.jpg').writeAsBytesSync(List.filled(20 * 1024 * 1024, 0));
    
    db.insertSyncQueue(SyncQueue(id: 'sync_4', state: SyncState.PENDING));
    db.insertMediaQueue(MediaQueue(
      id: 'media_4',
      syncQueueId: 'sync_4',
      filePath: 'auth4.jpg',
      totalSizeBytes: 20 * 1024 * 1024,
      state: MediaState.PENDING,
    ));
    
    await worker.processMedia('media_4');
    
    expect((await mediaRepo.getById(\1))!.state, MediaState.RETRY_PENDING);
    expect((await mediaRepo.getById(\1))!.uploadedBytes, 2 * 5 * 1024 * 1024);
  });

  test('Test F: Timeout Handling', () async {
    final db = GetIt.I<MockDatabase>();
    final worker = GetIt.I<MediaSyncWorker>();
    final transport = GetIt.I<MockMediaTransportService>();
    
    transport.injectTimeoutAtChunk = true; // Fails at chunk 2
    
    File('auth5.jpg').writeAsBytesSync(List.filled(20 * 1024 * 1024, 0));
    
    db.insertSyncQueue(SyncQueue(id: 'sync_5', state: SyncState.PENDING));
    db.insertMediaQueue(MediaQueue(
      id: 'media_5',
      syncQueueId: 'sync_5',
      filePath: 'auth5.jpg',
      totalSizeBytes: 20 * 1024 * 1024,
      state: MediaState.PENDING,
    ));
    
    await worker.processMedia('media_5');
    
    expect((await mediaRepo.getById(\1))!.state, MediaState.RETRY_PENDING);
    expect((await mediaRepo.getById(\1))!.uploadedBytes, 2 * 5 * 1024 * 1024);
  });
}
