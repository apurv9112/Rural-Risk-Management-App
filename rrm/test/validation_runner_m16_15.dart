import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:rrm/services/offline/auth_recovery_service.dart';
import 'package:rrm/services/offline/payload_assembly_service.dart';
import 'package:rrm/services/offline/sync_coordinator.dart';
import 'package:rrm/services/offline/queue_models.dart';
import 'package:rrm/services/offline/sync_status_service.dart';
import 'package:rrm/services/offline/media_sync_worker.dart';
import 'package:rrm/services/offline/queue_processor.dart';
import 'package:rrm/services/offline/mock_media_transport_service.dart';
import 'package:rrm/services/offline/queue_statistics_service.dart';
import 'package:rrm/widgets/sync_dashboard_widget.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    final getIt = GetIt.instance;
    await getIt.reset();
    
    final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

    getIt.registerSingleton<MockDatabase>(db);
    getIt.registerSingleton<SyncStatusService>(SyncStatusService());
    
    final transport = MockMediaTransportService();
    getIt.registerSingleton<MockMediaTransportService>(transport);
    
    getIt.registerSingleton<MediaSyncWorker>(MediaSyncWorker(
      transportService: transport,
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      authRecoveryService: MockAuthRecoveryService(),
    ));
    getIt.registerSingleton<QueueProcessor>(QueueProcessor(
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      assemblyService: PayloadAssemblyService(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo),
    ));
    getIt.registerSingleton<SyncCoordinator>(SyncCoordinator(
      mediaSyncWorker: getIt<MediaSyncWorker>(),
      queueProcessor: getIt<QueueProcessor>(),
      syncStatusService: getIt<SyncStatusService>(),
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
    ));
    
    final stats = QueueStatisticsService(syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo);
    stats.onInit();
    getIt.registerSingleton<QueueStatisticsService>(stats);
  });

  test('Test A & E: Statistics Accuracy & Queue Health Metrics', () async {
    final db = GetIt.I<MockDatabase>();
    final stats = GetIt.I<QueueStatisticsService>();
    
    // Initial state
    expect(stats.pendingMediaCount.value, 0);
    expect(stats.queueIntegrityStatus, 'Healthy');
    
    // Insert some data
    db.insertSyncQueue(SyncQueue(id: 'sync_1', state: SyncState.PENDING));
    db.insertMediaQueue(MediaQueue(
      id: 'media_1',
      syncQueueId: 'sync_1',
      filePath: 'test.jpg',
      totalSizeBytes: 1000,
      state: MediaState.PENDING,
    ));
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    expect(stats.pendingSyncCount.value, 1);
    expect(stats.pendingMediaCount.value, 1);
    expect(stats.totalQueueSizeBytes.value, 1000);
    
    // Test Orphan Media (Health)
    db.insertMediaQueue(MediaQueue(
      id: 'orphan_1',
      syncQueueId: 'non_existent_sync',
      filePath: 'orphan.jpg',
      totalSizeBytes: 500,
      state: MediaState.PENDING,
    ));
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    expect(stats.orphanMediaCount.value, 1);
    expect(stats.queueIntegrityStatus, 'Critical');
  });



  testWidgets('Test B, F, G: Dashboard Rendering and Live Progress', (WidgetTester tester) async {
    final db = GetIt.I<MockDatabase>();
    final syncStatus = GetIt.I<SyncStatusService>();
    
    db.insertSyncQueue(SyncQueue(id: 'sync_ui', state: SyncState.PENDING));
    db.insertMediaQueue(MediaQueue(
      id: 'media_ui',
      syncQueueId: 'sync_ui',
      filePath: 'ui.jpg',
      totalSizeBytes: 2048 * 1024, // 2MB
      state: MediaState.PENDING,
    ));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SyncDashboardWidget(),
          ),
        ),
      ),
    );

    // Initial render checks
    expect(find.text('SYNC STATUS'), findsOneWidget);
    expect(find.text('IDLE'), findsOneWidget);
    expect(find.text('Pending: 1'), findsNWidgets(2)); // Media and Record both 1
    expect(find.text('2.00 MB waiting for upload'), findsOneWidget);
    
    // Simulate live progress state change
    syncStatus.setStatus(SyncStateStatus.syncingMedia);
    (await mediaRepo.getById(\1))!.state = MediaState.UPLOADING;
    await mediaRepo.update(\1);
    
    await tester.pumpAndSettle();
    
    // Assert reactivity
    expect(find.text('SYNCING MEDIA'), findsOneWidget);
    expect(find.text('Uploading: 1'), findsOneWidget); // Media uploading
  });
}
