import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:rrm/services/offline/queue_models.dart';
import 'package:rrm/services/offline/sync_coordinator.dart';

class SyncQueuePage extends StatefulWidget {
  const SyncQueuePage({super.key});

  @override
  State<SyncQueuePage> createState() => _SyncQueuePageState();
}

class _SyncQueuePageState extends State<SyncQueuePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final db = GetIt.I<MockDatabase>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    db.onChange.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Queue Details'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Uploading'),
            Tab(text: 'Failed'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GetIt.I<SyncCoordinator>().requestManualSync();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(SyncState.PENDING),
          _buildList(SyncState.UPLOADING_MEDIA),
          _buildFailedList(),
          _buildList(SyncState.COMPLETED),
        ],
      ),
    );
  }

  Widget _buildList(SyncState state) {
    final items = db.syncQueues.values.where((q) {
      if (state == SyncState.PENDING) {
        return q.state == SyncState.PENDING || q.state == SyncState.ELIGIBLE_FOR_SYNC;
      }
      return q.state == state;
    }).toList();

    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildQueueCard(items[index]);
      },
    );
  }

  Widget _buildFailedList() {
    // In our mock, SyncQueue doesn't easily go to FAILED unless its media fails.
    // Let's find SyncQueues that have FAILED media.
    final failedMediaSyncIds = db.mediaQueues.values
        .where((m) => m.state == MediaState.FAILED)
        .map((m) => m.syncQueueId)
        .toSet();

    final items = db.syncQueues.values.where((q) => failedMediaSyncIds.contains(q.id)).toList();

    if (items.isEmpty) {
      return const Center(child: Text('No failed items found'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              GetIt.I<SyncCoordinator>().retryAllFailed();
            },
            child: const Text('Retry All Failed'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildQueueCard(items[index], isFailed: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueueCard(SyncQueue queue, {bool isFailed = false}) {
    final mediaItems = db.getMediaForSync(queue.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text('Queue ID: ${queue.id}'),
        subtitle: Text('Status: ${isFailed ? "FAILED" : queue.state.name} | Media: ${mediaItems.length}'),
        children: [
          if (isFailed)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  GetIt.I<SyncCoordinator>().retryFailedQueue(queue.id);
                },
                child: const Text('Retry Failed Items'),
              ),
            ),
          ...mediaItems.map((m) {
            double progress = m.totalSizeBytes > 0 ? m.uploadedBytes / m.totalSizeBytes : 0;
            return ListTile(
              dense: true,
              leading: Icon(
                m.state == MediaState.COMPLETED ? Icons.check_circle :
                m.state == MediaState.FAILED ? Icons.error :
                Icons.upload_file,
                color: m.state == MediaState.COMPLETED ? Colors.green :
                       m.state == MediaState.FAILED ? Colors.red : Colors.blue,
              ),
              title: Text(m.filePath.split('/').last),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('State: ${m.state.name}'),
                  LinearProgressIndicator(value: progress),
                  Text('${m.uploadedBytes} / ${m.totalSizeBytes} bytes'),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}
