import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rrm/services/base.dart';

class SignatureService {
  static const String baseUrl = baseAPIUrl;

  Future<http.StreamedResponse> uploadSignatures({
    required String token,
    required String leadId,
    required String leadType,
    required String folderId,
    required File customerSignature,
    required File fieldWorkerSignature,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/field-worker/save-signatures"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["leadId"] = leadId;
    request.fields["leadType"] = leadType;
    request.fields["folderId"] = folderId;

    request.files.add(
      await http.MultipartFile.fromPath(
        "customerSignature",
        customerSignature.path,
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "fieldWorkerSignature",
        fieldWorkerSignature.path,
      ),
    );

    return await request.send();
  }
}
