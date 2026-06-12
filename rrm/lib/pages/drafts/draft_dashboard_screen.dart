import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'draft_dashboard_controller.dart';
import 'package:rrm/data/models/draft_dashboard_item.dart';

class DraftDashboardScreen extends GetView<DraftDashboardController> {
  const DraftDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drafts & Sync Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadDrafts(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.drafts.isEmpty) {
          return const Center(child: Text("No active drafts or syncs."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.drafts.length,
          itemBuilder: (context, index) {
            final draft = controller.drafts[index];
            return _buildDraftCard(draft);
          },
        );
      }),
    );
  }

  Widget _buildDraftCard(DraftDashboardItem draft) {
    final statusColor = _getStatusColor(draft.syncStatus);
    final statusIcon = _getStatusIcon(draft.syncStatus);
    final statusText = _getStatusText(draft.syncStatus);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getWorkflowIcon(draft.workflowType), color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      draft.workflowType.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  _formatDate(draft.lastUpdatedAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Divider(),
            // Body
            Text("Farmer: ${draft.ownerName}", style: const TextStyle(fontSize: 15)),
            if (draft.mobileNumber.isNotEmpty)
              Text("Mobile: ${draft.mobileNumber}", style: const TextStyle(color: Colors.grey)),
            if (draft.village.isNotEmpty)
              Text("Village: ${draft.village}", style: const TextStyle(color: Colors.grey)),
            Text("Cattle Count: ${draft.totalCattleCount}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(statusIcon, color: Colors.white, size: 16),
                  label: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: statusColor,
                ),
                _buildActionButtons(draft),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(DraftDashboardItem draft) {
    if (draft.syncStatus == 'DEAD_LETTER') {
      return Row(
        children: [
          TextButton(
            onPressed: () => controller.viewError(draft),
            child: const Text("VIEW ERROR", style: TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(draft),
          )
        ],
      );
    } else if (draft.syncStatus == 'CONFLICT') {
      return TextButton(
        onPressed: () => controller.showConflictResolution(draft),
        child: const Text("RESOLVE", style: TextStyle(color: Colors.orange)),
      );
    } else if (draft.syncStatus == 'PENDING_SYNC' || draft.syncStatus == 'SYNCING') {
      return const SizedBox.shrink(); // No actions while syncing
    }

    // Default DRAFT actions
    return Row(
      children: [
        TextButton(
          onPressed: () => controller.resumeDraft(draft),
          child: const Text("RESUME"),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () => _confirmDelete(draft),
        )
      ],
    );
  }

  void _confirmDelete(DraftDashboardItem draft) {
    Get.defaultDialog(
      title: "Delete Draft?",
      middleText: "This action cannot be undone.",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      textCancel: "Cancel",
      onConfirm: () {
        controller.deleteDraft(draft.entityUuid);
        Get.back();
      },
    );
  }

  // --- Helpers ---
  Color _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT': return Colors.grey;
      case 'COMPLETED_LOCALLY':
      case 'PENDING_SYNC': return Colors.orange;
      case 'SYNCING': return Colors.blue;
      case 'SYNCED': return Colors.green;
      case 'DEAD_LETTER': return Colors.red;
      case 'CONFLICT': return Colors.amber;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'DRAFT': return Icons.edit_note;
      case 'COMPLETED_LOCALLY':
      case 'PENDING_SYNC': return Icons.cloud_queue;
      case 'SYNCING': return Icons.cloud_upload;
      case 'SYNCED': return Icons.cloud_done;
      case 'DEAD_LETTER': return Icons.error_outline;
      case 'CONFLICT': return Icons.warning_amber;
      default: return Icons.info_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DRAFT': return "Draft";
      case 'COMPLETED_LOCALLY':
      case 'PENDING_SYNC': return "Waiting for Network";
      case 'SYNCING': return "Syncing...";
      case 'SYNCED': return "Synced";
      case 'DEAD_LETTER': return "Sync Failed";
      case 'CONFLICT': return "Conflict Detected";
      default: return status;
    }
  }

  IconData _getWorkflowIcon(String type) {
    if (type.toLowerCase() == 'tagging') return Icons.pets;
    if (type.toLowerCase() == 'retagging') return Icons.autorenew;
    if (type.toLowerCase() == 'claim') return Icons.request_quote;
    return Icons.folder;
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      // Simple format for now
      return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }
}
