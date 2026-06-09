import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/data/models/draft_dashboard_item.dart';
import 'package:rrm/data/repositories/draft_repository.dart';
import 'package:rrm/data/repositories/conflict_repository.dart' as rrm_conflict;

class DraftDashboardController extends GetxController {
  final DraftRepository _draftRepository = DraftRepository();

  RxList<DraftDashboardItem> drafts = <DraftDashboardItem>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDrafts();
  }

  Future<void> loadDrafts() async {
    isLoading.value = true;
    try {
      final data = await _draftRepository.fetchDashboardDrafts();
      drafts.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Failed to load drafts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDraft(String localUuid) async {
    try {
      await _draftRepository.deleteDraft(localUuid);
      drafts.removeWhere((item) => item.entityUuid == localUuid);
      Get.snackbar("Success", "Draft deleted successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete draft: $e");
    }
  }

  void resumeDraft(DraftDashboardItem draft) {
    if (draft.syncStatus == 'IN_PROGRESS' || draft.syncStatus == 'SYNCING') {
      Get.snackbar("Wait", "This draft is currently syncing and cannot be edited.");
      return;
    }

    if (draft.workflowType.toUpperCase() == 'TAGGING') {
      // Resume tagging logic
      if (draft.lastScreenRoute.isNotEmpty) {
        Get.toNamed(draft.lastScreenRoute, arguments: {'leadUuid': draft.entityUuid});
      } else {
        Get.toNamed('/tagging', arguments: {'leadUuid': draft.entityUuid});
      }
    } else {
      Get.snackbar("Info", "Resumption for ${draft.workflowType} is under construction.");
    }
  }

  void viewError(DraftDashboardItem draft) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text("Sync Failed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Reason for failure:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              width: double.infinity,
              child: Text(draft.lastError ?? "Unknown error occurred during sync.", style: const TextStyle(fontFamily: 'monospace')),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _retrySync(draft.entityUuid);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("RETRY SYNC"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _retrySync(String localUuid) async {
    // Reset sync_queue status to PENDING
    // This requires a repository call, let's add it to DraftRepository
    try {
      await _draftRepository.retryDraft(localUuid);
      Get.snackbar("Success", "Draft sync retried. It will be processed in the background.");
      loadDrafts();
    } catch (e) {
      Get.snackbar("Error", "Failed to retry sync: $e");
    }
  }

  void showConflictResolution(DraftDashboardItem draft) async {
    final conflictRepo = rrm_conflict.ConflictRepository();
    final conflicts = await conflictRepo.getConflicts();
    
    final conflict = conflicts.firstWhereOrNull((c) => c['entity_uuid'] == draft.entityUuid);
    
    if (conflict == null) {
      Get.snackbar("Error", "Conflict details not found.");
      return;
    }

    final String localPayload = conflict['local_payload_json'] ?? '{}';
    final String serverPayload = conflict['server_payload_json'] ?? '{}';
    final String conflictUuid = conflict['conflict_uuid'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Version Conflict", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Local Data:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: SingleChildScrollView(child: Text(localPayload, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
              ),
              const SizedBox(height: 16),
              const Text("Server Data:", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade50,
                child: SingleChildScrollView(child: Text(serverPayload, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await conflictRepo.keepLocal(conflictUuid, draft.entityUuid);
                        Get.back();
                        Get.snackbar("Resolved", "Kept Local Version. Enqueued for sync.");
                        loadDrafts();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text("Keep Local"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await conflictRepo.keepServer(conflictUuid, draft.entityUuid);
                        Get.back();
                        Get.snackbar("Resolved", "Kept Server Version. Draft marked synced.");
                        loadDrafts();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("Keep Server"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
