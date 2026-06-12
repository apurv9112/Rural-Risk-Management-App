import 'package:get_it/get_it.dart';
import 'package:rrm/utils/validation_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';
import 'package:rrm/services/offline/sync_status_service.dart';
import 'package:rrm/services/offline/media_sync_worker.dart';
import 'package:rrm/services/offline/queue_processor.dart';
import 'package:rrm/services/offline/sync_coordinator.dart';
import 'package:rrm/services/offline/connectivity_service.dart';
import 'package:rrm/services/offline/background_sync_manager.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';

import 'package:rrm/services/offline/media_transport_service.dart';
import 'package:rrm/services/offline/mock_media_transport_service.dart';
import 'package:rrm/services/offline/real_media_transport_service.dart';
import 'package:rrm/services/offline/media_http_client.dart';
import 'package:rrm/services/offline/endpoint_provider.dart';
import 'package:rrm/services/offline/auth_recovery_service.dart';
import 'package:rrm/services/offline/payload_assembly_service.dart';
import 'package:rrm/services/offline/queue_statistics_service.dart';
import 'package:rrm/services/offline/queue_insertion_service.dart';

const bool isProduction = false; // Environment routing toggle

GetIt getIt = GetIt.instance;

FormValidations get formValidation => GetIt.I.get<FormValidations>();

void initDependencies() {
  getIt.registerLazySingleton<FormValidations>(() => FormValidations());
  getIt.registerLazySingleton<SnackbarHelper>(() => SnackbarHelper());
  
  // Offline Background Infrastructure
  // Offline Background Infrastructure
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  getIt.registerLazySingleton<SyncQueueRepository>(() => SyncQueueRepository(getIt<AppDatabase>()));
  getIt.registerLazySingleton<MediaQueueRepository>(() => MediaQueueRepository(getIt<AppDatabase>()));
  
  getIt.registerLazySingleton<SyncStatusService>(() => SyncStatusService());
  getIt.registerLazySingleton<QueueStatisticsService>(() => QueueStatisticsService(
    syncQueueRepository: getIt<SyncQueueRepository>(),
    mediaQueueRepository: getIt<MediaQueueRepository>(),
  ));
  
  getIt.registerLazySingleton<AuthRecoveryService>(() => MockAuthRecoveryService());
  
  getIt.registerLazySingleton<EndpointProvider>(() => EndpointProvider());
  getIt.registerLazySingleton<MediaHttpClient>(() => MediaHttpClient());
  
  if (isProduction) {
    getIt.registerLazySingleton<MediaTransportService>(() => RealMediaTransportService(
      endpointProvider: getIt<EndpointProvider>(),
      httpClient: getIt<MediaHttpClient>(),
    ));
  } else {
    getIt.registerLazySingleton<MediaTransportService>(() => MockMediaTransportService());
  }
  
  getIt.registerLazySingleton<MediaSyncWorker>(() => MediaSyncWorker(
    transportService: getIt<MediaTransportService>(),
    syncQueueRepository: getIt<SyncQueueRepository>(),
    mediaQueueRepository: getIt<MediaQueueRepository>(),
    authRecoveryService: getIt<AuthRecoveryService>(),
  ));
  
  getIt.registerLazySingleton<PayloadAssemblyService>(() => PayloadAssemblyService(
    syncQueueRepository: getIt<SyncQueueRepository>(),
    mediaQueueRepository: getIt<MediaQueueRepository>(),
  ));
  
  getIt.registerLazySingleton<QueueInsertionService>(() => QueueInsertionService(
    syncQueueRepository: getIt<SyncQueueRepository>(),
    mediaQueueRepository: getIt<MediaQueueRepository>(),
  ));
  
  getIt.registerLazySingleton<QueueProcessor>(() => QueueProcessor(
    syncQueueRepository: getIt<SyncQueueRepository>(),
    mediaQueueRepository: getIt<MediaQueueRepository>(),
    assemblyService: getIt<PayloadAssemblyService>(),
  ));
  
  getIt.registerLazySingleton<SyncCoordinator>(() => SyncCoordinator(
    mediaSyncWorker: getIt<MediaSyncWorker>(),
    queueProcessor: getIt<QueueProcessor>(),
    syncStatusService: getIt<SyncStatusService>(),
    syncQueueRepository: getIt<SyncQueueRepository>(),
    mediaQueueRepository: getIt<MediaQueueRepository>(),
  ));
  
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  
  getIt.registerLazySingleton<BackgroundSyncManager>(() => BackgroundSyncManager());
}
