import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:rrm/services/offline/queue_statistics_service.dart';
import 'package:rrm/services/offline/sync_status_service.dart';
import 'package:rrm/services/offline/sync_coordinator.dart';

class SyncDashboardWidget extends StatelessWidget {
  const SyncDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = GetIt.I<QueueStatisticsService>();
    final syncStatus = GetIt.I<SyncStatusService>();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SYNC STATUS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Obx(() {
                  final status = syncStatus.status.value;
                  return _buildStatusBadge(status);
                }),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Media Queue', style: TextStyle(fontWeight: FontWeight.bold)),
                      Obx(() => _buildStatRow('Pending', stats.pendingMediaCount.value, Colors.orange)),
                      Obx(() => _buildStatRow('Uploading', stats.uploadingMediaCount.value, Colors.blue)),
                      Obx(() => _buildStatRow('Failed', stats.failedMediaCount.value, Colors.red)),
                      Obx(() => _buildStatRow('Completed', stats.completedMediaCount.value, Colors.green)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Record Queue', style: TextStyle(fontWeight: FontWeight.bold)),
                      Obx(() => _buildStatRow('Pending', stats.pendingSyncCount.value, Colors.orange)),
                      Obx(() => _buildStatRow('Syncing', stats.syncingSyncCount.value, Colors.blue)),
                      Obx(() => _buildStatRow('Failed', stats.failedSyncCount.value, Colors.red)),
                      Obx(() => _buildStatRow('Completed', stats.completedSyncCount.value, Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Storage Usage', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Text('${(stats.totalQueueSizeBytes.value / (1024 * 1024)).toStringAsFixed(2)} MB waiting for upload')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last Successful Sync', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Obx(() => Text(
                        stats.lastSuccessfulSyncTime.value?.toString().split('.').first ?? 'Never',
                        style: const TextStyle(fontSize: 12),
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last Failed Sync', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Obx(() => Text(
                        stats.lastFailedSyncTime.value?.toString().split('.').first ?? 'Never',
                        style: const TextStyle(fontSize: 12),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Queue Health Section
            const Divider(),
            const SizedBox(height: 8),
            const Text('Queue Health', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => _buildHealthBadge(stats.queueIntegrityStatus)),
            Obx(() => Text('Orphan Media: ${stats.orphanMediaCount}', style: const TextStyle(fontSize: 12))),
            Obx(() => Text('Stale Locks: ${stats.staleLocksCount}', style: const TextStyle(fontSize: 12))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  GetIt.I<SyncCoordinator>().requestManualSync();
                },
                icon: const Icon(Icons.sync),
                label: const Text('Sync Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Text('$label: $count', style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SyncStateStatus status) {
    String label;
    Color color;
    switch (status) {
      case SyncStateStatus.idle:
        label = 'IDLE';
        color = Colors.grey;
        break;
      case SyncStateStatus.syncingMedia:
        label = 'SYNCING MEDIA';
        color = Colors.blue;
        break;
      case SyncStateStatus.syncingRecords:
        label = 'SYNCING RECORDS';
        color = Colors.blue;
        break;
      case SyncStateStatus.completed:
        label = 'COMPLETED';
        color = Colors.green;
        break;
      case SyncStateStatus.failed:
        label = 'FAILED';
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
  
  Widget _buildHealthBadge(String status) {
    Color color = Colors.green;
    if (status == 'Warning') color = Colors.orange;
    if (status == 'Critical') color = Colors.red;
    return Text(
      'Status: $status',
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}
