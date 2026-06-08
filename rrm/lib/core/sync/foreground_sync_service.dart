import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/repositories/sync_queue_repository.dart';
import 'executors/http_queue_executor.dart';
import 'queue_processor.dart';
import 'connectivity_monitor.dart';
import 'sync_coordinator.dart';
import '../database/app_database.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Re-initialize Database in the isolated background context
  await AppDatabase.instance.database;

  final repository = SyncQueueRepository();
  final executor = HttpQueueExecutor();
  final queueProcessor = QueueProcessor(repository: repository, executor: executor);
  final connectivityMonitor = ConnectivityMonitor();

  final coordinator = SyncCoordinator(
    queueProcessor: queueProcessor,
    connectivityMonitor: connectivityMonitor,
  );

  // Bring to foreground with notification
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "RRM Sync Service",
      content: "Syncing massive media backlog...",
    );
  }

  try {
    await coordinator.recoverCrashLocks();
    await coordinator.syncNow();
  } catch (e) {
    debugPrint('Foreground Sync Error: $e');
  }

  // Stop service when done
  service.stopSelf();
}

class ForegroundSyncService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'rrm_sync_channel', // id
      'RRM Sync Channel', // name
      description: 'This channel is used for massive media sync notifications.', // description
      importance: Importance.low, // low importance so it doesn't make a sound
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'rrm_sync_channel',
        initialNotificationTitle: 'RRM Sync Service',
        initialNotificationContent: 'Preparing sync...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
      ),
    );
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (!isRunning) {
      service.startService();
    }
  }
}
