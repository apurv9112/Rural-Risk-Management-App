import '../../../data/models/sync_queue_model.dart';

import '../models/sync_execution_result.dart';

abstract class QueueExecutor {
  /// Executes a queue job.
  /// Returns a SyncExecutionResult indicating success, retryable failure, or fatal failure.
  Future<SyncExecutionResult> execute(SyncQueueModel job);
}

