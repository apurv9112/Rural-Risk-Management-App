import 'dart:convert';
import 'package:http/http.dart' as http;

class TaggingService {
  TaggingService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = "https://ruralrisk.in/api";
  final http.Client _client;

  Future<http.Response> listAssigned({required String token}) {
    return _client.get(
      Uri.parse("$baseUrl/field-worker/my-leads?leadType=tagging"),
      headers: _authHeaders(token),
    );
  }

  Future<http.Response> searchTagging({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _client
        .post(
          Uri.parse("$baseUrl/tagging/search"),
          headers: _authHeaders(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
  }

  Future<http.Response> manualTagging({
    required String token,
    required Map<String, dynamic> body,
  }) {
    return _client.post(
      Uri.parse("$baseUrl/tagging/manually/"),
      headers: _authHeaders(token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getTagging({required String token, required String id}) {
    return _client.get(
      Uri.parse("$baseUrl/tagging/$id"),
      headers: _authHeaders(token),
    );
  }

  Future<http.Response> cancelLead({required String token, required String id, Map<String, dynamic>? body}) {
    return _client.patch(
      Uri.parse("$baseUrl/tagging/cancellead/$id"),
      headers: _authHeaders(token),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> updateLead({required String token, required String id, required Map<String, dynamic> body}) {
    return _client.patch(
      Uri.parse("$baseUrl/tagging/$id"),
      headers: _authHeaders(token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> completed({required String token, String status = "Attended"}) {
    return _client
        .post(
          Uri.parse("$baseUrl/tagging/search"),
          headers: _authHeaders(token),
          body: jsonEncode({"status": status, "page": 1, "limit": 50}),
        )
        .timeout(const Duration(seconds: 30));
  }

  Future<http.Response> searchCompleted({required String token, required String searchString}) {
    return _client
        .post(
          Uri.parse("$baseUrl/tagging/search"),
          headers: _authHeaders(token),
          body: jsonEncode({"searchString": searchString, "status": "Attended", "page": 1, "limit": 50}),
        )
        .timeout(const Duration(seconds: 30));
  }

  Future<http.Response> downloadHealthCertificate({required String token, required String id}) {
    return _client.get(
      Uri.parse("$baseUrl/tagging/health-certificate/$id"),
      headers: _authHeaders(token),
    );
  }

  Future<http.Response> downloadAllHealthCertificates({required String token}) {
    return _client.get(
      Uri.parse("$baseUrl/tagging/health-certificate/all"),
      headers: _authHeaders(token),
    );
  }

  Map<String, String> _authHeaders(String token) => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
}
