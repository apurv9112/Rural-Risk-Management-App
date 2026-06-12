import 'dart:convert';
import 'package:http/http.dart' as http;
import 'transport_exceptions.dart';

class MediaHttpClient {
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  // A generic mockable handler for testing purposes
  http.Client? mockClient;

  Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body) async {
    final client = mockClient ?? http.Client();
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _handleResponseStatus(response.statusCode, response.body);
      
      return jsonDecode(response.body);
    } catch (e) {
      if (e is TransportException) rethrow;
      throw NetworkException(e.toString());
    } finally {
      if (mockClient == null) client.close();
    }
  }

  Future<Map<String, dynamic>> postMultipartChunk(String url, String uploadId, int chunkIndex, List<int> bytes) async {
    final client = mockClient ?? http.Client();
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      request.fields['uploadId'] = uploadId;
      request.fields['chunkIndex'] = chunkIndex.toString();
      
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      request.files.add(http.MultipartFile.fromBytes('chunk', bytes, filename: 'chunk_$chunkIndex'));

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      _handleResponseStatus(response.statusCode, response.body);
      
      return jsonDecode(response.body);
    } catch (e) {
      if (e is TransportException) rethrow;
      throw NetworkException(e.toString());
    } finally {
      if (mockClient == null) client.close();
    }
  }

  void _handleResponseStatus(int statusCode, String body) {
    if (statusCode >= 200 && statusCode < 300) {
      return; // Success
    } else if (statusCode == 401) {
      throw AuthenticationException("Token expired or invalid: $body");
    } else if (statusCode == 403) {
      throw ForbiddenException("Forbidden access: $body");
    } else if (statusCode == 429) {
      throw RateLimitException("Rate limited: $body");
    } else if (statusCode == 408 || statusCode == 504) {
      throw TimeoutException("Timeout: $body");
    } else if (statusCode >= 500) {
      throw ServerException("Server error: $body");
    } else if (statusCode == 404) {
      throw TransportException(404, "Not Found / Missing File: $body");
    } else if (statusCode == 400) {
      throw TransportException(400, "Bad Request (e.g. Invalid Checksum): $body");
    } else {
      throw TransportException(statusCode, "Unknown HTTP Error: $body");
    }
  }
}
