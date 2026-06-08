import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rrm/data/dao/media_dao.dart';
import 'package:rrm/services/base.dart';
import 'queue_executor.dart';
import '../../../data/models/sync_queue_model.dart';
import '../models/sync_execution_result.dart';

class HttpQueueExecutor implements QueueExecutor {
  final http.Client client;
  final MediaDao mediaDao;

  HttpQueueExecutor({http.Client? client, MediaDao? mediaDao}) 
    : client = client ?? http.Client(),
      mediaDao = mediaDao ?? MediaDao();

  @override
  Future<SyncExecutionResult> execute(SyncQueueModel job) async {
    final Map<String, dynamic> payload = jsonDecode(job.payloadJson ?? '{}');
    // Using a dummy token for offline simulation purposes unless we pull it from storage.
    final token = 'mock-auth-token'; 
    final idempotencyKey = job.queueUuid;

    try {
      if (job.entityType == 'lead') {
        return await _syncLead(payload, token, idempotencyKey);
      } else if (job.entityType == 'cattle') {
        return await _syncCattle(job.entityUuid!, payload, token, idempotencyKey);
      } else if (job.entityType == 'media') {
        // Media is natively uploaded WITH Cattle in the backend's multipart endpoint.
        // If a discrete media job fires, it is a no-op or handled as KYC.
        return SyncExecutionResult(success: true, responseCode: 200);
      }

      return SyncExecutionResult(
        success: false,
        responseCode: 422,
        errorMessage: 'Unknown entity type: ${job.entityType}',
      );
    } catch (e) {
      return SyncExecutionResult(
        success: false,
        responseCode: 500, // Timeout/SocketException map to 500 locally
        errorMessage: e.toString(),
      );
    }
  }

  Future<SyncExecutionResult> _syncLead(Map<String, dynamic> payload, String token, String idempotencyKey) async {
    final uri = Uri.parse('$baseAPIUrl/tagging/manually/');
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'X-Idempotency-Key': idempotencyKey,
      },
      body: jsonEncode(payload),
    );

    return _parseResponse(response);
  }

  Future<SyncExecutionResult> _syncCattle(String cattleUuid, Map<String, dynamic> payload, String token, String idempotencyKey) async {
    final uri = Uri.parse('$baseAPIUrl/field-worker/save-cattle');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['X-Idempotency-Key'] = idempotencyKey;

    // Map text fields
    payload.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    // Dynamically query the MediaDao to aggregate physical files into this cattle request!
    final mediaList = await mediaDao.getByCattleId(cattleUuid);
    
    for (final media in mediaList) {
      if (media.absoluteLocalPath != null) {
        final file = File(media.absoluteLocalPath!);
        if (await file.exists()) {
          final multipartFile = await http.MultipartFile.fromPath(
            media.captureType ?? 'files', // Map to the API's expected field names
            file.path,
          );
          request.files.add(multipartFile);
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _parseResponse(response);
  }

  SyncExecutionResult _parseResponse(http.Response response) {
    final success = response.statusCode >= 200 && response.statusCode < 300;
    String? serverId;

    if (success) {
      try {
        final body = jsonDecode(response.body);
        // Extract typical identifiers if present
        serverId = body['data']?['id']?.toString() ?? body['id']?.toString();
      } catch (_) {}
    }

    return SyncExecutionResult(
      success: success,
      responseCode: response.statusCode,
      serverId: serverId,
      errorMessage: success ? null : response.body,
      responsePayload: response.body,
    );
  }
}
