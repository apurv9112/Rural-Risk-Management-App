// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class KycService {
//   KycService({http.Client? client}) : _client = client ?? http.Client();

//   static const String baseUrl = "https://ruralrisk.in/api";
//   final http.Client _client;

//   Future<http.Response> updateKyc({
//     required String token,
//     required String taggingId,
//     required Map<String, dynamic> payload,
//     required String leadId,
//   }) {
//     return _client
//         .patch(
//           Uri.parse("$baseUrl/tagging/$taggingId"),
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $token",
//           },
//           body: jsonEncode(payload),
//         )
//         .timeout(const Duration(seconds: 30));
//   }

//   Future<http.Response> uploadOwnerDocuments({
//     required String token,
//     required String ownerId,
//     required Map<String, dynamic> payload,
//   }) {
//     return _client.post(
//       Uri.parse("$baseUrl/owner/kyc/documents/$ownerId"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//       body: jsonEncode(payload),
//     );
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

class KycService {
  final String baseUrl = "https://ruralrisk.in/api"; // 🔁 replace this

  Future<http.Response> updateKyc({
    required String token,
    required String leadId,
    required Map<String, dynamic> payload,
  }) async {
    final url = Uri.parse("$baseUrl/kyc/update/$leadId"); // ✅ FIXED

    print("========== KYC API DEBUG ==========");
    print("URL → $url");
    print("PAYLOAD → ${jsonEncode(payload)}");
    print("===================================");

    final response = await http.patch(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    print("STATUS → ${response.statusCode}");
    print("BODY → ${response.body}");

    return response;
  }
}
