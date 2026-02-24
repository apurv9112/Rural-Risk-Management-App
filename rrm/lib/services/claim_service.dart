import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaimService {
  ClaimService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = "https://ruralrisk.in/api";
  final http.Client _client;

  Future<http.Response> listAssigned({required String token}) {
    return _client.get(
      Uri.parse("$baseUrl/field-worker/my-leads?leadType=claim"),
      headers: _authHeaders(token),
    );
  }

  Future<http.Response> getById({required String token, required String id}) {
    return _client.get(
      Uri.parse("$baseUrl/claim/$id"),
      headers: _authHeaders(token),
    );
  }

  Future<http.Response> cancelLead({required String token, required String id, Map<String, dynamic>? body}) {
    return _client.patch(
      Uri.parse("$baseUrl/claim/cancellead/$id"),
      headers: _authHeaders(token),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> updateLead({required String token, required String id, required Map<String, dynamic> body}) {
    return _client.patch(
      Uri.parse("$baseUrl/claim/$id"),
      headers: _authHeaders(token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> completed({required String token, String status = "Attended"}) {
    return _client
        .get(
          Uri.parse("$baseUrl/field-worker/my-leads?leadType=claim&status=$status"),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 30));
  }

  Future<http.Response> searchCompleted({required String token, required String searchString}) {
    return _client
        .get(
          Uri.parse("$baseUrl/field-worker/my-leads?leadType=claim&status=Attended"),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 30));
  }

  Future<http.Response> downloadCertificate({required String token, required String id}) {
    return _client.get(
      Uri.parse("$baseUrl/claim/claim-certificate/$id"),
      headers: _authHeaders(token),
    );
  }

  Future<http.Response> downloadAllCertificates({required String token}) {
    return _client.get(
      Uri.parse("$baseUrl/claim/claim-certificate/all"),
      headers: _authHeaders(token),
    );
  }

  Map<String, String> _authHeaders(String token) => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
}
