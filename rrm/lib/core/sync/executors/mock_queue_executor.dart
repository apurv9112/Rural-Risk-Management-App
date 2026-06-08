import 'queue_executor.dart';
import '../../../data/models/sync_queue_model.dart';
import '../models/sync_execution_result.dart';

class MockQueueExecutor implements QueueExecutor {
  final bool shouldSucceed;
  final bool isFatal;

  MockQueueExecutor({this.shouldSucceed = true, this.isFatal = false});

  @override
  Future<SyncExecutionResult> execute(SyncQueueModel job) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (!shouldSucceed) {
      if (isFatal) {
        return SyncExecutionResult(
          success: false,
          responseCode: 422,
          errorMessage: 'FATAL_ERROR: Permanent failure mock',
        );
      } else {
        return SyncExecutionResult(
          success: false,
          responseCode: 500,
          errorMessage: 'NETWORK_ERROR: Transient failure mock',
        );
      }
    }
    
    return SyncExecutionResult(
      success: true,
      responseCode: 200,
      serverId: 'mock-server-uuid-1234',
    );
  }

}
