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

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class KycService {
//   final String baseUrl = "https://ruralrisk.in/api";

//   Future<http.Response> uploadKyc({
//     required String token,
//     required String ownerId,
//     required Map<String, dynamic> payload,
//   }) async {
//     final url = Uri.parse("$baseUrl/owner/kyc/documents/$ownerId");

//     print("========== KYC API DEBUG ==========");
//     print("URL → $url");
//     print("PAYLOAD → ${jsonEncode(payload)}");
//     print("===================================");

//     final response = await http.post(
//       url,
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//       },
//       body: jsonEncode(payload),
//     );

//     print("STATUS → ${response.statusCode}");
//     print("BODY → ${response.body}");

//     return response;
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class KycService {
  static const String baseUrl = "https://ruralrisk.in/api";

  Future<Map<String, dynamic>> uploadKyc({
    required String token,
    required String leadId,
    required String leadType,
    required List<File> files,
  }) async {
    final uri = Uri.parse("$baseUrl/field-worker/save-kyc");

    print("========== NEW KYC API ==========");
    print("URL => $uri");
    print("LEAD ID => $leadId");
    print("LEAD TYPE => $leadType");
    print("FILES COUNT => ${files.length}");
    print("=================================");

    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({"Authorization": "Bearer $token"});

    request.fields["leadId"] = leadId;
    request.fields["leadType"] = leadType;

    for (File file in files) {
      request.files.add(await http.MultipartFile.fromPath("files", file.path));

      print("ADDING FILE => ${file.path}");
    }

    final streamedResponse = await request.send();

    final responseBody = await streamedResponse.stream.bytesToString();

    print("STATUS => ${streamedResponse.statusCode}");
    print("BODY => $responseBody");

    return {"statusCode": streamedResponse.statusCode, "body": responseBody};
  }
}
