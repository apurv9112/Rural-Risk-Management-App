
import 'package:uuid/uuid.dart';
import '../models/sync_queue_model.dart';
import 'base_repository.dart';

class SyncQueueRepository extends BaseRepository {
  static const String queueTable = 'sync_queue';
  static const _uuid = Uuid();

  /// Creates a new job in the queue.
  /// If [dependencyQueueUuid] is provided, the initial state is WAITING_DEPENDENCY.
  /// Otherwise, it is PENDING.
  Future<SyncQueueModel> createJob({
    required String entityType,
    required String entityUuid,
    required String operationType,
    required String payloadJson,
    String? dependencyQueueUuid,
  }) async {
    final status = dependencyQueueUuid != null ? 'WAITING_DEPENDENCY' : 'PENDING';
    final now = DateTime.now().toIso8601String();

    final job = SyncQueueModel(
      queueUuid: _uuid.v4(),
      dependencyQueueUuid: dependencyQueueUuid,
      entityType: entityType,
      entityUuid: entityUuid,
      operationType: operationType,
      payloadJson: payloadJson,
      status: status,
      attemptCount: 0,
      idempotencyKey: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
    );

    final database = await db;
    await database.insert(queueTable, job.toMap());
    return job;
  }

  /// Transitions a job to a new state. Validates allowed transitions.
  Future<void> updateJobState(String queueUuid, String currentState, String newState, {String? lastError, String? nextRetryAt}) async {
    if (!_isValidTransition(currentState, newState)) {
      throw Exception('Invalid state transition from $currentState to $newState');
    }

    final database = await db;
    final Map<String, dynamic> updateData = {
      'status': newState,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (lastError != null) {
      updateData['last_error'] = lastError;
    }
    if (nextRetryAt != null) {
      updateData['next_retry_at'] = nextRetryAt;
    }

    if (newState == 'IN_PROGRESS') {
      updateData['processing_started_at'] = DateTime.now().toIso8601String();
      // Increment attempt count
      await database.rawUpdate(
        'UPDATE $queueTable SET attempt_count = attempt_count + 1 WHERE queue_uuid = ?',
        [queueUuid]
      );
    }

    await database.update(
      queueTable,
      updateData,
      where: 'queue_uuid = ?',
      whereArgs: [queueUuid],
    );
  }

  /// Evaluates WAITING_DEPENDENCY jobs to see if their dependencies are COMPLETED.
  Future<void> resolveDependencies() async {
    final database = await db;
    // Find jobs that are waiting, but their dependency job has status 'COMPLETED'
    final List<Map<String, dynamic>> maps = await database.rawQuery('''
      SELECT q.queue_uuid 
      FROM $queueTable q
      INNER JOIN $queueTable dep ON q.dependency_queue_uuid = dep.queue_uuid
      WHERE q.status = 'WAITING_DEPENDENCY' AND dep.status = 'COMPLETED'
    ''');

    for (final row in maps) {
      await updateJobState(row['queue_uuid'] as String, 'WAITING_DEPENDENCY', 'PENDING');
    }
  }

  /// Retrieves up to [limit] jobs that are PENDING or RETRY_SCHEDULED (and whose retry time has passed).
  Future<List<SyncQueueModel>> getNextBatch({int limit = 10}) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> maps = await database.query(
      queueTable,
      where: '(status = ?) OR (status = ? AND (next_retry_at IS NULL OR next_retry_at <= ?))',
      whereArgs: ['PENDING', 'RETRY_SCHEDULED', now],
      orderBy: 'created_at ASC',
      limit: limit,
    );

    return maps.map((e) => SyncQueueModel.fromMap(e)).toList();
  }

  /// Internal logic verifying State Machine transitions
  bool _isValidTransition(String from, String to) {
    switch (from) {
      case 'WAITING_DEPENDENCY':
        return to == 'PENDING' || to == 'DEAD_LETTER';
      case 'PENDING':
      case 'RETRY_SCHEDULED':
        return to == 'IN_PROGRESS';
      case 'IN_PROGRESS':
        return to == 'COMPLETED' || to == 'RETRY_SCHEDULED' || to == 'DEAD_LETTER';
      case 'COMPLETED':
      case 'DEAD_LETTER':
        return false; // Terminal states
      default:
        return false;
    }
  }
}
