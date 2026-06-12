import 'package:workmanager/workmanager.dart';
import 'package:get_it/get_it.dart';
import 'sync_coordinator.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';

import 'media_sync_worker.dart';
import 'queue_processor.dart';
import 'sync_status_service.dart';
import 'mock_media_transport_service.dart';
import 'real_media_transport_service.dart';
import 'media_http_client.dart';
import 'endpoint_provider.dart';
import 'auth_recovery_service.dart';
import 'payload_assembly_service.dart';
import 'media_transport_service.dart';

const bool isProduction = false; // Must match the main one for tests

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Because this runs in a separate isolate on Android, we must re-initialize our DI setup for the background context.
      final getIt = GetIt.instance;
      
      if (!getIt.isRegistered<AppDatabase>()) {
        getIt.registerSingleton<AppDatabase>(AppDatabase.instance);
        getIt.registerSingleton<SyncQueueRepository>(SyncQueueRepository(getIt<AppDatabase>()));
        getIt.registerSingleton<MediaQueueRepository>(MediaQueueRepository(getIt<AppDatabase>()));
        
        getIt.registerSingleton<SyncStatusService>(SyncStatusService());
        getIt.registerSingleton<AuthRecoveryService>(MockAuthRecoveryService());
        
        getIt.registerSingleton<EndpointProvider>(EndpointProvider());
        getIt.registerSingleton<MediaHttpClient>(MediaHttpClient());
        
        if (isProduction) {
          getIt.registerSingleton<MediaTransportService>(RealMediaTransportService(
            endpointProvider: getIt<EndpointProvider>(),
            httpClient: getIt<MediaHttpClient>(),
          ));
        } else {
          getIt.registerSingleton<MediaTransportService>(MockMediaTransportService());
        }

        getIt.registerSingleton<MediaSyncWorker>(MediaSyncWorker(
          transportService: getIt<MediaTransportService>(),
          syncQueueRepository: getIt<SyncQueueRepository>(),
          mediaQueueRepository: getIt<MediaQueueRepository>(),
          authRecoveryService: getIt<AuthRecoveryService>(),
        ));
        getIt.registerSingleton<PayloadAssemblyService>(PayloadAssemblyService(
          syncQueueRepository: getIt<SyncQueueRepository>(),
          mediaQueueRepository: getIt<MediaQueueRepository>(),
        ));
        getIt.registerSingleton<QueueProcessor>(QueueProcessor(
          syncQueueRepository: getIt<SyncQueueRepository>(),
          mediaQueueRepository: getIt<MediaQueueRepository>(),
          assemblyService: getIt<PayloadAssemblyService>(),
        ));
        getIt.registerSingleton<SyncCoordinator>(SyncCoordinator(
          mediaSyncWorker: getIt<MediaSyncWorker>(),
          queueProcessor: getIt<QueueProcessor>(),
          syncStatusService: getIt<SyncStatusService>(),
          syncQueueRepository: getIt<SyncQueueRepository>(),
          mediaQueueRepository: getIt<MediaQueueRepository>(),
        ));
      }

      final coordinator = getIt<SyncCoordinator>();
      
      // Attempt recovery in case app died during a previous sync
      await coordinator.recoverStaleLocks();

      // Execute sync
      await coordinator.onNetworkAvailable();

      return Future.value(true);
    } catch (e) {
      return Future.value(false); // Indicates failure, might trigger retry depending on constraints
    }
  });
}

class BackgroundSyncManager {
  static const String periodicSyncTask = "periodicSyncTask";
  static const String recoverySyncTask = "recoverySyncTask";

  void init() {
    Workmanager().initialize(
      callbackDispatcher,
    );
    
    _registerPeriodicTask();
  }

  void _registerPeriodicTask() {
    Workmanager().registerPeriodicTask(
      "1", // Unique Name
      periodicSyncTask,
      frequency: const Duration(minutes: 15), // Minimum periodic interval on Android
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when connected
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep, // Survives reboot naturally if keeping policy
    );
  }

  void registerRecoveryTask() {
    Workmanager().registerOneOffTask(
      "2", // Unique Name
      recoverySyncTask,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}
