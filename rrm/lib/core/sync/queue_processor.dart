import 'dart:math';
import '../../data/models/sync_queue_model.dart';
import '../../data/dao/leads_dao.dart';
import '../../data/dao/cattle_dao.dart';
import '../../data/repositories/sync_queue_repository.dart';

import 'executors/queue_executor.dart';
import 'foreground_sync_service.dart';

class QueueProcessor {
  final SyncQueueRepository repository;
  final QueueExecutor executor;
  final LeadsDao leadsDao = LeadsDao();
  final CattleDao cattleDao = CattleDao();

  QueueProcessor({
    required this.repository,
    required this.executor,
  });

  /// Main processing loop
  Future<void> processQueue() async {
    // 1. Resolve any blocked dependencies first
    await repository.resolveDependencies();

    // 2. Fetch eligible jobs
    final jobs = await repository.getNextBatch(limit: 50); // Fetch more to check backlog

    if (jobs.isEmpty) return;

    // 3. Detect Massive Media Backlog
    final mediaJobsCount = jobs.where((j) => j.operationType == 'UPLOAD_MEDIA').length;
    if (mediaJobsCount > 10) {
      // Promote to Foreground Service to survive Doze/App Killers
      await ForegroundSyncService.startService();
      // Wait, if we are ALREADY in the foreground service, calling startService is a no-op.
    }

    for (final job in jobs) {
      await _processJob(job);
    }
  }

  Future<void> _processJob(SyncQueueModel job) async {
    // Attempt state transition
    try {
      await repository.updateJobState(job.queueUuid, job.status!, 'IN_PROGRESS');
    } catch (e) {
      // Job might have been updated concurrently by another thread/process
      return;
    }

    try {
      // Execute payload
      final result = await executor.execute(job);

      if (result.success) {
        // Map local_uuid to server_id if returned
        if (result.serverId != null && job.entityUuid != null) {
          if (job.entityType == 'lead') {
            final lead = await leadsDao.getById(job.entityUuid!);
            if (lead != null) {
              await leadsDao.update(lead); // Mock mapping update logic natively
            }
          } else if (job.entityType == 'cattle') {
            final cattle = await cattleDao.getById(job.entityUuid!);
            if (cattle != null) {
              await cattleDao.update(cattle); // Mock mapping update logic
            }
          }
        }
        await repository.updateJobState(job.queueUuid, 'IN_PROGRESS', 'COMPLETED');
      } else {
        throw Exception(result.isFatal ? 'FATAL: ${result.responseCode}' : 'RETRY: ${result.responseCode}');
      }
      
    } catch (e) {
      // On Failure
      final errorStr = e.toString();
      final isFatal = errorStr.contains('FATAL');
      final attemptCount = job.attemptCount ?? 0;

      if (isFatal || attemptCount >= 6) {
        // Move to Dead Letter if fatal or max retries exceeded
        await repository.updateJobState(
          job.queueUuid, 
          'IN_PROGRESS', 
          'DEAD_LETTER', 
          lastError: errorStr
        );
      } else {
        // Schedule Retry with Exponential Backoff
        // Base delay = 1 minute. delay = 1 * (2 ^ attemptCount)
        final delayMinutes = pow(2, attemptCount).toInt();
        final nextRetryAt = DateTime.now().add(Duration(minutes: delayMinutes)).toIso8601String();

        await repository.updateJobState(
          job.queueUuid, 
          'IN_PROGRESS', 
          'RETRY_SCHEDULED', 
          lastError: errorStr,
          nextRetryAt: nextRetryAt
        );
      }
    }
  }
}
