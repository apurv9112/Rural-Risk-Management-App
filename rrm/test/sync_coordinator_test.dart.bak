import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/migrations/migration_manager.dart';
import 'package:rrm/core/sync/connectivity_monitor.dart';

import 'package:rrm/core/sync/sync_coordinator.dart';
import 'package:rrm/core/sync/queue_processor.dart';
import 'package:rrm/core/sync/executors/mock_queue_executor.dart';
import 'package:rrm/data/repositories/sync_queue_repository.dart';

// Mock connectivity monitor that allows manual toggling
class MockConnectivityMonitor extends ConnectivityMonitor {
  bool _mockIsOnline = false;
  final StreamController<bool> _mockController = StreamController<bool>.broadcast();

  @override
  bool get isOnline => _mockIsOnline;

  @override
  Stream<bool> get connectivityStream => _mockController.stream;

  void setOnline(bool online) {
    _mockIsOnline = online;
    _mockController.add(online);
  }
}

// Dummy queue processor that tracks execution count and allows fake processing time
class MockQueueProcessor extends QueueProcessor {
  int executeCount = 0;
  final int delayMs;

  MockQueueProcessor(this.delayMs) : super(
    repository: SyncQueueRepository(),
    executor: MockQueueExecutor()
  );

  @override
  Future<void> processQueue() async {
    executeCount++;
    await Future.delayed(Duration(milliseconds: delayMs));
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SyncCoordinator Tests', () {
    late Database db;
    late MockConnectivityMonitor monitor;

    setUp(() async {
      db = await databaseFactory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
              version: 1,
              onCreate: (db, version) async {
                await MigrationManager.createInitialSchema(db);
              }));
      // Assign the test db directly if needed, but AppDatabase is singleton. 
      // This is a unit test limitation, but we can test logic.
      monitor = MockConnectivityMonitor();
    });

    tearDown(() async {
      await db.close();
    });

    test('Validation 1 & 2: Offline prevents sync, Online triggers sync exactly once', () async {
      final processor = MockQueueProcessor(10);
      final coordinator = SyncCoordinator(
        queueProcessor: processor,
        connectivityMonitor: monitor,
      );

      // Initially offline
      monitor.setOnline(false);
      await coordinator.initialize();
      await coordinator.syncNow();
      
      expect(processor.executeCount, 0);

      // Transition to online
      monitor.setOnline(true);
      // Wait for stream event to propagate
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(processor.executeCount, 1);
    });

    test('Validation 3 & 4: Flapping and overlapping execution protected', () async {
      final processor = MockQueueProcessor(100); // 100ms execution
      final coordinator = SyncCoordinator(
        queueProcessor: processor,
        connectivityMonitor: monitor,
      );

      await coordinator.initialize();

      // Trigger multiple rapid events
      monitor.setOnline(true); // Should start sync 1
      coordinator.syncNow(); // Should ignore (locked)
      monitor.setOnline(false); 
      monitor.setOnline(true); // Should ignore (locked)
      
      await Future.delayed(const Duration(milliseconds: 20));
      // Manual trigger during run
      coordinator.syncNow(); // Should ignore (locked)

      await Future.delayed(const Duration(milliseconds: 200));

      // After 200ms, the lock is released. 
      // Only 1 execution should have happened.
      expect(processor.executeCount, 1);
    });
  });
}
