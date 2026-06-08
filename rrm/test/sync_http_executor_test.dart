import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rrm/core/sync/executors/http_queue_executor.dart';
import 'package:rrm/data/models/sync_queue_model.dart';
import 'package:rrm/data/dao/media_dao.dart';

import 'package:rrm/data/models/media_metadata_model.dart';

// Dummy subclass to mock MediaDao
class MockMediaDao extends MediaDao {
  @override
  Future<List<MediaMetadataModel>> getByCattleId(String cattleId) async {
    return [];
  }
}


void main() {
  group('HttpQueueExecutor Tests', () {
    test('Successful Lead Sync stores serverId', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['X-Idempotency-Key'], 'uuid-1234');
        return http.Response('{"data": {"id": "server-999"}}', 200);
      });

      final executor = HttpQueueExecutor(client: mockClient, mediaDao: MockMediaDao());
      
      final job = SyncQueueModel(
        queueUuid: 'uuid-1234',
        entityType: 'lead',
        entityUuid: 'local-L1',
        operationType: 'CREATE',
        payloadJson: '{"name":"test"}',
        status: 'IN_PROGRESS',
        idempotencyKey: 'uuid-1234',
      );


      final result = await executor.execute(job);
      
      expect(result.success, true);
      expect(result.responseCode, 200);
      expect(result.serverId, 'server-999');
    });

    test('Retryable Failure maps to 500', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });

      final executor = HttpQueueExecutor(client: mockClient, mediaDao: MockMediaDao());
      
      final job = SyncQueueModel(
        queueUuid: 'uuid-1234',
        entityType: 'lead',
        entityUuid: 'local-L1',
        operationType: 'CREATE',
        payloadJson: '{}',
        status: 'IN_PROGRESS',
        idempotencyKey: 'uuid-1234',
      );

      final result = await executor.execute(job);
      
      expect(result.success, false);
      expect(result.isRetryable, true);
      expect(result.isFatal, false);
    });

    test('Fatal Failure maps to 422', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Validation Failed', 422);
      });

      final executor = HttpQueueExecutor(client: mockClient, mediaDao: MockMediaDao());
      
      final job = SyncQueueModel(
        queueUuid: 'uuid-1234',
        entityType: 'lead',
        entityUuid: 'local-L1',
        operationType: 'CREATE',
        payloadJson: '{}',
        status: 'IN_PROGRESS',
        idempotencyKey: 'uuid-1234',
      );

      final result = await executor.execute(job);
      
      expect(result.success, false);
      expect(result.isRetryable, false);
      expect(result.isFatal, true);
    });
  });
}
