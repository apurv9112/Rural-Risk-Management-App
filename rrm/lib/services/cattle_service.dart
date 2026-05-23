import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rrm/services/base.dart';

class CattleService {
  CattleService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = baseAPIUrl;

  final http.Client _client;

  Future<http.StreamedResponse> submitCattle({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/field-worker/save-cattle"),
    );

    // ================= HEADERS =================

    request.headers['Authorization'] = "Bearer $token";

    // ================= TEXT FIELDS =================

    payload.forEach((key, value) {
      if (value != null && value is! File) {
        request.fields[key] = value.toString();
      }
    });

    // ================= FILE ADD FUNCTION =================

    Future<void> addFile(String field, dynamic file) async {
      if (file != null && file is File) {
        request.files.add(await http.MultipartFile.fromPath(field, file.path));
      }
    }

    // ================= MAIN IMAGES =================

    await addFile("earTagImage", payload["earTagImage"]);

    await addFile("headPoseImage", payload["headPoseImage"]);

    await addFile("sidePoseLeftImage", payload["sidePoseLeftImage"]);

    await addFile("sidePoseRightImage", payload["sidePoseRightImage"]);

    await addFile("backPoseImage", payload["backPoseImage"]);

    await addFile("earCutPhoto", payload["earCutPhoto"]);

    await addFile("earBackSidePhoto", payload["earBackSidePhoto"]);

    // ================= TAGGING COPY =================

    await addFile("taggingEarTagImage", payload["taggingEarTagImage"]);

    await addFile("taggingHeadPoseImage", payload["taggingHeadPoseImage"]);

    await addFile(
      "taggingSidePoseLeftImage",
      payload["taggingSidePoseLeftImage"],
    );

    await addFile(
      "taggingSidePoseRightImage",
      payload["taggingSidePoseRightImage"],
    );

    await addFile("taggingBackPoseImage", payload["taggingBackPoseImage"]);

    // ================= OLD IMAGES =================

    await addFile("oldEarTagImage", payload["oldEarTagImage"]);

    await addFile("oldHeadPoseImage", payload["oldHeadPoseImage"]);

    await addFile("oldSidePoseLeftImage", payload["oldSidePoseLeftImage"]);

    await addFile("oldSidePoseRightImage", payload["oldSidePoseRightImage"]);

    await addFile("oldBackPoseImage", payload["oldBackPoseImage"]);

    // ================= VIDEOS =================

    await addFile("reTaggingVideo", payload["reTaggingVideo"]);

    await addFile("fullCattleVideo", payload["fullCattleVideo"]);

    // ================= PDF =================

    await addFile("conversionPdf", payload["conversionPdf"]);

    // ================= SEND =================

    return await request.send();
  }
}
