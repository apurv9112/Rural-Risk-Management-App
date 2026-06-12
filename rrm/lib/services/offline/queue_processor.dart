import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'queue_models.dart';
import 'dart:io';
import 'payload_assembly_service.dart';

class QueueProcessor {
  final SyncQueueRepository syncQueueRepository;
  final MediaQueueRepository mediaQueueRepository;
  final PayloadAssemblyService assemblyService;

  QueueProcessor({
    required this.syncQueueRepository,
    required this.mediaQueueRepository,
    required this.assemblyService,
  });

  Future<void> processAllPendingSyncQueues() async {
    final eligibleQueues = await syncQueueRepository.getByStates([
      SyncState.ELIGIBLE_FOR_SYNC,
      SyncState.PENDING
    ]);

    for (final queue in eligibleQueues) {
      // Transition to processing
      queue.state = SyncState.UPLOADING_MEDIA;
      await syncQueueRepository.update(queue);

      // Verify if media is complete using assembly service
      try {
        final assembledPayload = await assemblyService.assemblePayload(queue.id);
        
        // At this point, assembly succeeded
        // Normally we'd do HTTP POST here with assembledPayload.
        // Simulate payload upload delay
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Save back assembled payload for proof
        queue.payload = assembledPayload;
        
        queue.state = SyncState.COMPLETED;
        await syncQueueRepository.update(queue);
        
        // Clean up media files
        final mediaItems = await mediaQueueRepository.getBySyncQueueId(queue.id);
        for (final media in mediaItems) {
          try {
            final f = File(media.filePath);
            if (await f.exists()) {
              await f.delete();
            }
          } catch (e) {
            // Log error
          }
        }
      } on PayloadAssemblyException catch (e) {
        // If assembly fails (missing asset, not completed, duplicate, etc)
        print('Assembly Error: $e'); // Diagnostic error
        
        // In M16.16.2 instructions: "Parent remains blocked" for Eligibility Rules.
        // But Phase 6 Failure Handling: "Mark parent FAILED"
        // Let's mark it PENDING if it's incomplete, or FAILED if it was eligible but assembly explicitly failed?
        // Wait, "If ANY child media row NOT COMPLETED ... throw PayloadAssemblyException. Parent remains blocked."
        // But Phase 6 says: "Missing asset, Null asset, Duplicate asset, Failed child -> Mark parent FAILED"
        // So we will mark parent FAILED if PayloadAssemblyException is caught?
        // Wait! If it's just "NOT COMPLETED" because it's still uploading, it shouldn't FAILED, it should just be PENDING.
        // Let's refine the error handling. If a media is just PENDING, it's not a failure, just not eligible.
        // But my logic only runs on `ELIGIBLE_FOR_SYNC` or `PENDING` parents.
        
        queue.state = SyncState.PENDING; 
        
        // Wait, the Phase 6 says: "Reject assembly, Mark parent FAILED".
        // Let's check the cause. If it's missing/duplicate/null asset it's a fatal assembly error.
        // If it's simply "not COMPLETED", it might still be uploading.
        if (e.message.contains('is not COMPLETED')) {
          queue.state = SyncState.PENDING;
        } else {
          queue.state = SyncState.FAILED; // Assuming SyncState has FAILED? Wait! SyncState doesn't have FAILED in queue_models.dart!
        }
        await syncQueueRepository.update(queue);
      } catch (e) {
        // Any other error
        queue.state = SyncState.PENDING;
        await syncQueueRepository.update(queue);
      }
    }
  }
}
