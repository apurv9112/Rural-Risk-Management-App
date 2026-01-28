import 'dart:convert';
import 'package:http/http.dart' as http;

class KycService {
  KycService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = "https://ruralrisk.in/api";
  final http.Client _client;

  Future<http.Response> updateKyc({
    required String token,
    required String taggingId,
    required Map<String, dynamic> payload,
  }) {
    return _client
        .patch(
          Uri.parse("$baseUrl/tagging/$taggingId"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));
  }

  Future<http.Response> uploadOwnerDocuments({
    required String token,
    required String ownerId,
    required Map<String, dynamic> payload,
  }) {
    return _client.post(
      Uri.parse("$baseUrl/owner/kyc/documents/$ownerId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );
  }
}
