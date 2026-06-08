import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/migrations/migration_manager.dart';
import 'package:rrm/data/repositories/sync_queue_repository.dart';
import 'package:rrm/core/sync/queue_processor.dart';
import 'package:rrm/core/sync/executors/mock_queue_executor.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Sync Queue Tests', () {
    late Database db;
    late SyncQueueRepository repo;

    setUp(() async {
      db = await databaseFactory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
              version: 1,
              onCreate: (db, version) async {
                await MigrationManager.createInitialSchema(db);
              }));
      repo = SyncQueueRepository();
    });

    tearDown(() async {
      await db.close();
    });

    test('Queue State Machine Transitions', () async {
      final job = await repo.createJob(
        entityType: 'lead',
        entityUuid: '123',
        operationType: 'CREATE',
        payloadJson: '{}',
      );
      
      expect(job.status, 'PENDING');

      // Valid: PENDING -> IN_PROGRESS
      await repo.updateJobState(job.queueUuid, 'PENDING', 'IN_PROGRESS');
      
      // Valid: IN_PROGRESS -> COMPLETED
      await repo.updateJobState(job.queueUuid, 'IN_PROGRESS', 'COMPLETED');
      
      // Invalid transition check: COMPLETED -> RETRY_SCHEDULED
      expect(
        () async => await repo.updateJobState(job.queueUuid, 'COMPLETED', 'RETRY_SCHEDULED'),
        throwsException,
      );
    });

    test('Dependency Resolution (Lead -> Cattle)', () async {
      final leadJob = await repo.createJob(
        entityType: 'lead',
        entityUuid: 'L1',
        operationType: 'CREATE',
        payloadJson: '{}',
      );

      final cattleJob = await repo.createJob(
        entityType: 'cattle',
        entityUuid: 'C1',
        operationType: 'CREATE',
        payloadJson: '{}',
        dependencyQueueUuid: leadJob.queueUuid, // Depends on Lead
      );

      expect(cattleJob.status, 'WAITING_DEPENDENCY');

      // Processor runs
      final processor = QueueProcessor(
        repository: repo,
        executor: MockQueueExecutor(shouldSucceed: true),
      );

      await processor.processQueue();
      // Only Lead should have run because cattle was WAITING.
      // Processor transitions Lead to COMPLETED.

      // Now resolve dependencies. Cattle should move to PENDING.
      await repo.resolveDependencies();
      
      // Re-fetch cattle job
      final nextBatch = await repo.getNextBatch();
      expect(nextBatch.length, 1);
      expect(nextBatch.first.queueUuid, cattleJob.queueUuid);
      expect(nextBatch.first.status, 'PENDING');
    });

    test('Queue Processor Failures and Dead Letter', () async {
      final fatalProcessor = QueueProcessor(
        repository: repo,
        executor: MockQueueExecutor(shouldSucceed: false, isFatal: true),
      );

      final job = await repo.createJob(
        entityType: 'lead',
        entityUuid: 'bad_lead',
        operationType: 'CREATE',
        payloadJson: '{}',
      );

      await fatalProcessor.processQueue();
      
      // Re-fetch job status directly using sql
      final result = await db.query('sync_queue', where: 'queue_uuid = ?', whereArgs: [job.queueUuid]);
      expect(result.first['status'], 'DEAD_LETTER');
    });
  });
}
