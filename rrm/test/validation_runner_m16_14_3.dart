import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rrm/services/offline/sync_coordinator.dart';
import 'package:rrm/services/offline/media_sync_worker.dart';
import 'package:rrm/services/offline/mock_media_transport_service.dart';
import 'package:rrm/services/offline/queue_processor.dart';
import 'package:rrm/services/offline/sync_status_service.dart';
import 'package:rrm/services/offline/queue_models.dart';
import 'package:rrm/services/offline/auth_recovery_service.dart';
import 'package:rrm/services/offline/payload_assembly_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Lock Recovery Test', () async {
    final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

    
    // Create a stuck media queue
    final stuckMedia = MediaQueue(
      id: 'stuck_media_1',
      syncQueueId: 'sync_1',
      filePath: 'dummy.jpg',
      totalSizeBytes: 100,
      state: MediaState.UPLOADING,
    );
    await mediaRepo.insert(\1);

    // Create a stuck sync queue
    final stuckQueue = SyncQueue(
      id: 'stuck_sync_1',
      state: SyncState.UPLOADING_MEDIA,
    );
    await syncRepo.insert(\1);

    final transport = MockMediaTransportService();
    final worker = MediaSyncWorker(transportService: transport, syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo, authRecoveryService: MockAuthRecoveryService());
    final queueProcessor = QueueProcessor(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo, assemblyService: PayloadAssemblyService(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo));
    final statusService = SyncStatusService();
    
    final coordinator = SyncCoordinator(
      mediaSyncWorker: worker,
      queueProcessor: queueProcessor,
      syncStatusService: statusService,
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
    );

    expect((await mediaRepo.getById(\1))!.state, MediaState.UPLOADING);
    expect((await syncRepo.getById(\1))!.state, SyncState.UPLOADING_MEDIA);

    await coordinator.recoverStaleLocks();

    expect((await mediaRepo.getById(\1))!.state, MediaState.PENDING);
    expect((await syncRepo.getById(\1))!.state, SyncState.PENDING);
  });

  test('Status Propagation and Collision Tests', () async {
    final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

    
    final transport = MockMediaTransportService();
    final worker = MediaSyncWorker(transportService: transport, syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo, authRecoveryService: MockAuthRecoveryService());
    final queueProcessor = QueueProcessor(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo, assemblyService: PayloadAssemblyService(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo));
    final statusService = SyncStatusService();
    
    final coordinator = SyncCoordinator(
      mediaSyncWorker: worker,
      queueProcessor: queueProcessor,
      syncStatusService: statusService,
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
    );

    // Track status changes
    final statuses = <SyncStateStatus>[];
    statusService.status.listen((s) {
      statuses.add(s);
    });

    // Attempt to trigger concurrent syncs
    final f1 = coordinator.init();

    // Small delay to let init lock it
    await Future.delayed(const Duration(milliseconds: 10));

    final f2 = coordinator.requestManualSync();
    final f3 = coordinator.onNetworkAvailable();

    await Future.wait([f1, f2, f3]);
    
    // Wait for the final Future.delayed to reset to idle
    await Future.delayed(const Duration(seconds: 3));

    // Expecting: idle -> syncingMedia -> syncingRecords -> completed -> idle
    expect(statuses.contains(SyncStateStatus.syncingMedia), isTrue);
    expect(statuses.contains(SyncStateStatus.syncingRecords), isTrue);
    expect(statuses.contains(SyncStateStatus.completed), isTrue);
    expect(statuses.last, SyncStateStatus.idle);
  });
}
