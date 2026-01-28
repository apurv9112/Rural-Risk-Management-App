import 'dart:convert';
import 'package:http/http.dart' as http;

class CattleService {
  CattleService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = "https://ruralrisk.in/api";
  final http.Client _client;

  Future<http.Response> submitCattle({
    required String token,
    required Map<String, dynamic> payload,
  }) {
    return _client
        .post(
          Uri.parse("$baseUrl/cattle"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));
  }
}
