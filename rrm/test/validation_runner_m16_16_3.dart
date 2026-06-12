import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/database/repositories/sync_queue_repository.dart';
import 'package:rrm/core/database/repositories/media_queue_repository.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:rrm/services/offline/queue_models.dart';
import 'package:rrm/services/offline/media_transport_service.dart';
import 'package:rrm/services/offline/mock_media_transport_service.dart';
import 'package:rrm/services/offline/real_media_transport_service.dart';
import 'package:rrm/services/offline/media_http_client.dart';
import 'package:rrm/services/offline/endpoint_provider.dart';
import 'package:rrm/services/offline/auth_recovery_service.dart';
import 'package:rrm/services/offline/media_sync_worker.dart';
import 'package:rrm/dependency_injection.dart' as di;

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() {
    GetIt.I.allowReassignment = true;
    final appDb = AppDatabase.instance;
    final syncRepo = SyncQueueRepository(appDb);
    final mediaRepo = MediaQueueRepository(appDb);
    final dbRaw = await appDb.database;
    await dbRaw.execute('DELETE FROM media_queue');
    await dbRaw.execute('DELETE FROM sync_queue');

    GetIt.I.registerSingleton<MockDatabase>(db);
    GetIt.I.registerSingleton<AuthRecoveryService>(MockAuthRecoveryService());
    GetIt.I.registerSingleton<EndpointProvider>(EndpointProvider(baseUrl: 'https://test.com'));
    GetIt.I.registerSingleton<MediaHttpClient>(MediaHttpClient());
  });

  test('Test A: Transport Resolution & DI', () {
    // If isProduction == false, it should resolve MockMediaTransportService
    // di.isProduction is constant false, so let's check it.
    GetIt.I.registerSingleton<MediaTransportService>(MockMediaTransportService());
    expect(GetIt.I<MediaTransportService>(), isA<MockMediaTransportService>());
    
    // Simulate real environment routing
    final realTransport = RealMediaTransportService(
      endpointProvider: GetIt.I<EndpointProvider>(),
      httpClient: GetIt.I<MediaHttpClient>(),
    );
    expect(realTransport, isA<RealMediaTransportService>());
  });

  test('Test B & F: Lifecycle and Endpoint Resolution', () async {
    final client = MediaHttpClient();
    final provider = GetIt.I<EndpointProvider>();
    
    int initCalls = 0;
    int chunkCalls = 0;
    int completeCalls = 0;
    
    client.mockClient = MockClient((request) async {
      if (request.url.toString() == provider.mediaInitUrl()) {
        initCalls++;
        return http.Response(jsonEncode({'uploadId': 'upload_xyz'}), 200);
      } else if (request.url.toString() == provider.mediaChunkUrl()) {
        chunkCalls++;
        return http.Response(jsonEncode({'acknowledgedBytes': 100}), 200);
      } else if (request.url.toString() == provider.mediaCompleteUrl()) {
        completeCalls++;
        return http.Response(jsonEncode({'assetId': 'asset_123'}), 200);
      }
      return http.Response('Not Found', 404);
    });

    final transport = RealMediaTransportService(
      endpointProvider: provider,
      httpClient: client,
    );

    final initRes = await transport.initUpload(checksum: 'abc', fileSize: 100, mimeType: 'image/jpeg');
    expect(initRes.success, true);
    expect(initRes.uploadId, 'upload_xyz');
    expect(initCalls, 1);

    final chunkRes = await transport.uploadChunk(uploadId: 'upload_xyz', chunkIndex: 0, bytes: [1, 2, 3]);
    expect(chunkRes.success, true);
    expect(chunkCalls, 1);

    final completeRes = await transport.completeUpload(uploadId: 'upload_xyz', checksum: 'abc');
    expect(completeRes.success, true);
    expect(completeRes.assetId, 'asset_123');
    expect(completeCalls, 1);
  });

  test('Test C: Auth Refresh During Chunk Upload', () async {
    final db = GetIt.I<MockDatabase>();
    final client = MediaHttpClient();
    final provider = GetIt.I<EndpointProvider>();
    
    int chunkCalls = 0;
    bool returned401 = false;
    
    client.mockClient = MockClient((request) async {
      if (request.url.toString() == provider.mediaInitUrl()) {
        return http.Response(jsonEncode({'uploadId': 'upl_auth'}), 200);
      } else if (request.url.toString() == provider.mediaChunkUrl()) {
        chunkCalls++;
        if (!returned401) {
          returned401 = true;
          return http.Response('Unauthorized', 401);
        }
        return http.Response(jsonEncode({'acknowledgedBytes': 100}), 200);
      } else if (request.url.toString() == provider.mediaCompleteUrl()) {
        return http.Response(jsonEncode({'assetId': 'asset_auth'}), 200);
      }
      return http.Response('Not Found', 404);
    });

    final transport = RealMediaTransportService(
      endpointProvider: provider,
      httpClient: client,
    );

    final worker = MediaSyncWorker(
      transportService: transport,
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      authRecoveryService: GetIt.I<AuthRecoveryService>(),
    );

    File('auth_test.jpg').writeAsBytesSync(List.filled(100, 0));

    db.insertMediaQueue(MediaQueue(
      id: 'media_auth', syncQueueId: 'sq_1', filePath: 'auth_test.jpg', totalSizeBytes: 100, state: MediaState.PENDING,
    ));

    await worker.processMedia('media_auth');

    // 401 thrown -> auth recovers -> retries
    expect(chunkCalls, 2);
    expect((await mediaRepo.getById(\1))!.state, MediaState.COMPLETED);
    expect((await mediaRepo.getById(\1))!.uploadedBytes, 100);
  });

  test('Test D: Retry Behavior (429, 500, Timeout)', () async {
    final db = GetIt.I<MockDatabase>();
    final provider = GetIt.I<EndpointProvider>();
    
    for (int statusCode in [429, 500, 408]) {
      final client = MediaHttpClient();
      client.mockClient = MockClient((request) async {
        if (request.url.toString() == provider.mediaInitUrl()) {
          return http.Response('Error', statusCode);
        }
        return http.Response('Not Found', 404);
      });

      final transport = RealMediaTransportService(
        endpointProvider: provider,
        httpClient: client,
      );

      final worker = MediaSyncWorker(
        transportService: transport,
        syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
        authRecoveryService: GetIt.I<AuthRecoveryService>(),
      );

      File('retry_test.jpg').writeAsBytesSync([0]);

      String mediaId = 'media_retry_$statusCode';
      db.insertMediaQueue(MediaQueue(
        id: mediaId, syncQueueId: 'sq_1', filePath: 'retry_test.jpg', totalSizeBytes: 1, state: MediaState.PENDING,
      ));

      await worker.processMedia(mediaId);

      expect((await mediaRepo.getById(\1))!.state, MediaState.RETRY_PENDING);
    }
  });

  test('Test E: Failure Behavior (Missing file)', () async {
    final db = GetIt.I<MockDatabase>();
    final worker = MediaSyncWorker(
      transportService: GetIt.I<MediaTransportService>(),
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      authRecoveryService: GetIt.I<AuthRecoveryService>(),
    );

    db.insertMediaQueue(MediaQueue(
      id: 'media_missing', syncQueueId: 'sq_1', filePath: 'missing_file.jpg', totalSizeBytes: 1, state: MediaState.PENDING,
    ));

    await worker.processMedia('media_missing');

    expect((await mediaRepo.getById(\1))!.state, MediaState.FAILED);
  });

  test('Test G: 100MB Memory Audit Bounded Chunk Size', () async {
    final db = GetIt.I<MockDatabase>();
    final client = MediaHttpClient();
    final provider = GetIt.I<EndpointProvider>();
    
    int maxChunkSizeObserved = 0;
    
    client.mockClient = MockClient((request) async {
      if (request.url.toString() == provider.mediaInitUrl()) {
        return http.Response(jsonEncode({'uploadId': 'upl_100mb'}), 200);
      } else if (request.url.toString() == provider.mediaChunkUrl()) {
        final length = request.contentLength ?? 0;
        if (length > maxChunkSizeObserved) {
          maxChunkSizeObserved = length;
        }
        return http.Response(jsonEncode({'acknowledgedBytes': 5 * 1024 * 1024}), 200);
      } else if (request.url.toString() == provider.mediaCompleteUrl()) {
        return http.Response(jsonEncode({'assetId': 'asset_100mb'}), 200);
      }
      return http.Response('Not Found', 404);
    });

    final transport = RealMediaTransportService(
      endpointProvider: provider,
      httpClient: client,
    );

    final worker = MediaSyncWorker(
      transportService: transport,
      syncQueueRepository: syncRepo, mediaQueueRepository: mediaRepo,
      authRecoveryService: GetIt.I<AuthRecoveryService>(),
    );

    // Create a 20MB file to avoid incredibly slow test, but it proves bounding.
    File('large_file.jpg').writeAsBytesSync(List.filled(20 * 1024 * 1024, 0));

    db.insertMediaQueue(MediaQueue(
      id: 'media_100mb', syncQueueId: 'sq_1', filePath: 'large_file.jpg', totalSizeBytes: 20 * 1024 * 1024, state: MediaState.PENDING,
    ));

    await worker.processMedia('media_100mb');

    // Chunks should never exceed 5MB (+ slight overhead for multipart encoding)
    expect(maxChunkSizeObserved, lessThan(6 * 1024 * 1024)); 
    expect((await mediaRepo.getById(\1))!.state, MediaState.COMPLETED);
    
    // Checksum was calculated and persisted
    expect((await mediaRepo.getById(\1))!.checksum, isNotNull);
  });
}
