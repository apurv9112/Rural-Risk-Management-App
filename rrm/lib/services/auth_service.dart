import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = "https://ruralrisk.in/api";
  final http.Client _client;

  Future<http.Response> login(Map<String, dynamic> payload) {
    return _client.post(
      Uri.parse("$baseUrl/auth/field-worker/login"),
      headers: const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> refresh(Map<String, dynamic> payload) {
    return _client.post(
      Uri.parse("$baseUrl/auth/refresh"),
      headers: const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> registerDevice(Map<String, dynamic> payload) {
    return _client.post(
      Uri.parse("$baseUrl/devices/register"),
      headers: const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> getDevice(String deviceId, {required String token}) {
    return _client.get(
      Uri.parse("$baseUrl/devices/$deviceId"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }
}
