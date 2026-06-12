import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:rrm/services/offline/queue_models.dart';
import 'package:rrm/services/offline/payload_assembly_service.dart';
import 'package:rrm/services/offline/queue_processor.dart';
import 'package:rrm/services/offline/media_sync_worker.dart';
import 'package:rrm/services/offline/mock_media_transport_service.dart';
import 'package:rrm/services/offline/auth_recovery_service.dart';
import 'dart:io';

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
    GetIt.I.registerSingleton<PayloadAssemblyService>(PayloadAssemblyService(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo));
    
    // Add MediaSyncWorker and Transport to help test Eligibility rules
    final transport = MockMediaTransportService();
    GetIt.I.registerSingleton<AuthRecoveryService>(MockAuthRecoveryService());
    GetIt.I.registerSingleton<MediaSyncWorker>(MediaSyncWorker(
      transportService: transport,
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      authRecoveryService: GetIt.I<AuthRecoveryService>(),
    ));
    GetIt.I.registerSingleton<QueueProcessor>(QueueProcessor(
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      assemblyService: GetIt.I<PayloadAssemblyService>(),
    ));
  });

  test('Test A & B: Single and Multi Asset Injection', () {
    final db = GetIt.I<MockDatabase>();
    final service = GetIt.I<PayloadAssemblyService>();

    db.insertSyncQueue(SyncQueue(
      id: 'sync_1',
      payload: {'name': 'Cow 1'},
    ));

    db.insertMediaQueue(MediaQueue(
      id: 'media_1',
      syncQueueId: 'sync_1',
      filePath: 'a.jpg',
      totalSizeBytes: 100,
      state: MediaState.COMPLETED,
      remoteAssetId: 'asset_earTag',
      fieldName: 'earTagImage',
    ));

    db.insertMediaQueue(MediaQueue(
      id: 'media_2',
      syncQueueId: 'sync_1',
      filePath: 'b.jpg',
      totalSizeBytes: 100,
      state: MediaState.COMPLETED,
      remoteAssetId: 'asset_headPose',
      fieldName: 'headPoseImage',
    ));

    final assembled = service.assemblePayload('sync_1');
    expect(assembled['earTagImageAssetId'], 'asset_earTag');
    expect(assembled['headPoseImageAssetId'], 'asset_headPose');
    expect(assembled['name'], 'Cow 1');
  });

  test('Test C: Array Reconstruction Strict Ordering', () {
    final db = GetIt.I<MockDatabase>();
    final service = GetIt.I<PayloadAssemblyService>();

    db.insertSyncQueue(SyncQueue(id: 'sync_2', payload: {}));

    // Insert out of order
    db.insertMediaQueue(MediaQueue(
      id: 'media_3', syncQueueId: 'sync_2', filePath: 'c.jpg', totalSizeBytes: 100,
      state: MediaState.COMPLETED, remoteAssetId: 'asset_2', fieldName: 'files', arrayIndex: 2,
    ));
    db.insertMediaQueue(MediaQueue(
      id: 'media_4', syncQueueId: 'sync_2', filePath: 'c.jpg', totalSizeBytes: 100,
      state: MediaState.COMPLETED, remoteAssetId: 'asset_0', fieldName: 'files', arrayIndex: 0,
    ));
    db.insertMediaQueue(MediaQueue(
      id: 'media_5', syncQueueId: 'sync_2', filePath: 'c.jpg', totalSizeBytes: 100,
      state: MediaState.COMPLETED, remoteAssetId: 'asset_1', fieldName: 'files', arrayIndex: 1,
    ));

    final assembled = service.assemblePayload('sync_2');
    
    // Expect exact order: asset_0, asset_1, asset_2
    final array = assembled['filesAssetIds'] as List<String>;
    expect(array.length, 3);
    expect(array[0], 'asset_0');
    expect(array[1], 'asset_1');
    expect(array[2], 'asset_2');
  });

  test('Test D: Missing Asset Protection (Null remote_asset_id)', () {
    final db = GetIt.I<MockDatabase>();
    final service = GetIt.I<PayloadAssemblyService>();

    db.insertSyncQueue(SyncQueue(id: 'sync_3', payload: {}));

    db.insertMediaQueue(MediaQueue(
      id: 'media_6', syncQueueId: 'sync_3', filePath: 'd.jpg', totalSizeBytes: 100,
      state: MediaState.COMPLETED, remoteAssetId: null, fieldName: 'earTagImage',
    ));

    expect(() => service.assemblePayload('sync_3'), throwsA(isA<PayloadAssemblyException>()));
  });

  test('Test E: Incomplete Media Protection', () {
    final db = GetIt.I<MockDatabase>();
    final service = GetIt.I<PayloadAssemblyService>();

    db.insertSyncQueue(SyncQueue(id: 'sync_4', payload: {}));

    db.insertMediaQueue(MediaQueue(
      id: 'media_7', syncQueueId: 'sync_4', filePath: 'e.jpg', totalSizeBytes: 100,
      state: MediaState.UPLOADING, remoteAssetId: 'asset_123', fieldName: 'earTagImage',
    ));

    expect(() => service.assemblePayload('sync_4'), throwsA(isA<PayloadAssemblyException>()));
  });

  test('Test F: Parent Eligibility', () async {
    final db = GetIt.I<MockDatabase>();
    final worker = GetIt.I<MediaSyncWorker>();
    
    File('testF.jpg').writeAsBytesSync([1,2,3]);

    db.insertSyncQueue(SyncQueue(id: 'sync_5', state: SyncState.PENDING, payload: {}));
    db.insertMediaQueue(MediaQueue(
      id: 'media_8', syncQueueId: 'sync_5', filePath: 'testF.jpg', totalSizeBytes: 3,
      state: MediaState.PENDING, remoteAssetId: null, fieldName: 'earTagImage',
    ));

    // Initially pending
    expect((await syncRepo.getById(\1))!.state, SyncState.PENDING);

    // Process media (simulating upload)
    await worker.processMedia('media_8');

    // After successful upload, child is completed, parent is eligible
    expect((await mediaRepo.getById(\1))!.state, MediaState.COMPLETED);
    expect((await mediaRepo.getById(\1))!.remoteAssetId, isNotNull);
    
    // Parent eligibility transition should have happened
    expect((await syncRepo.getById(\1))!.state, SyncState.ELIGIBLE_FOR_SYNC);
  });

  test('Test G: 10,000 Row Performance Audit', () {
    final db = GetIt.I<MockDatabase>();
    final service = GetIt.I<PayloadAssemblyService>();

    db.insertSyncQueue(SyncQueue(id: 'sync_perf', payload: {}));

    for (int i = 0; i < 10000; i++) {
      db.insertMediaQueue(MediaQueue(
        id: 'media_perf_$i', syncQueueId: 'sync_perf', filePath: 'p.jpg', totalSizeBytes: 1,
        state: MediaState.COMPLETED, remoteAssetId: 'asset_$i', fieldName: 'files', arrayIndex: i,
      ));
    }

    final stopwatch = Stopwatch()..start();
    final assembled = service.assemblePayload('sync_perf');
    stopwatch.stop();

    expect((assembled['filesAssetIds'] as List<String>).length, 10000);
    expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should assemble 10k array under 500ms
  });
}
