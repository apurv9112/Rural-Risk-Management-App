import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rrm/services/base.dart';

class KycService {
  static const String baseUrl = baseAPIUrl;

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
