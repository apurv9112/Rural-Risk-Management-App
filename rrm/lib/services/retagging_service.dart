import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rrm/services/base.dart';

class RetaggingService {
  RetaggingService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = baseAPIUrl;
  final http.Client _client;

  Future<http.Response> listAssigned({required String token}) {
    return _client.get(
      Uri.parse(
        "$baseUrl/field-worker/my-leads?status=Pending&leadType=retagging",
      ),
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
    String database = "retagging",
  }) {
    return _client
        .get(
          Uri.parse(
            "$baseUrl/field-worker/database?database=$database&page=1&limit=50&searchString=",
          ),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 30));
  }

  Future<http.Response> searchCompleted({
    required String token,
    required String searchString,
    String database = "retagging",
  }) {
    return _client
        .get(
          Uri.parse(
            "$baseUrl/field-worker/database?database=$database&page=1&limit=50&searchString=$searchString",
          ),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 30));
  }

  Map<String, String> _authHeaders(String token) => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<http.Response> downloadHealthCertificate({
    required String token,
    required String tagNo,
  }) {
    return _client.get(
      Uri.parse("$baseUrl/field-worker/health-certificates/$tagNo/download"),
      headers: _authHeaders(token),
    );
  }
}
