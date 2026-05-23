import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rrm/services/base.dart';

class RetaggingService {
  RetaggingService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = baseAPIUrl;
  final http.Client _client;

  Future<http.Response> listAssigned({required String token}) {
    return _client.get(
      Uri.parse("$baseUrl/field-worker/my-leads?leadType=retagging"),
      headers: _authHeaders(token),
    );
  }

  Future<http.Response> getById({required String token, required String id}) {
    return _client.get(
      Uri.parse("$baseUrl/retagging/$id"),
      headers: _authHeaders(token),
    );
  }

  Future<http.Response> updateLead({
    required String token,
    required String id,
    required Map<String, dynamic> body,
  }) {
    return _client.patch(
      Uri.parse("$baseUrl/retagging/$id"),
      headers: _authHeaders(token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> completed({
    required String token,
    String status = "Attended",
  }) {
    return _client.post(
      Uri.parse("$baseUrl/retagging/search"),
      headers: _authHeaders(token),
      body: jsonEncode({"status": status, "page": 1, "limit": 50}),
    );
  }

  Future<http.Response> searchCompleted({
    required String token,
    required String searchString,
  }) {
    return _client.post(
      Uri.parse("$baseUrl/retagging/search"),
      headers: _authHeaders(token),
      body: jsonEncode({
        "searchString": searchString,
        "status": "Attended",
        "page": 1,
        "limit": 50,
      }),
    );
  }

  Future<http.Response> downloadCertificate({
    required String token,
    required String id,
  }) {
    return _client.post(
      Uri.parse("$baseUrl/retagging/export"),
      headers: _authHeaders(token),
      body: jsonEncode({
        "ids": [id],
      }),
    );
  }

  Future<http.Response> downloadAllCertificates({required String token}) {
    return _client.post(
      Uri.parse("$baseUrl/retagging/export"),
      headers: _authHeaders(token),
      body: jsonEncode({"ids": []}),
    );
  }

  Map<String, String> _authHeaders(String token) => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
}
