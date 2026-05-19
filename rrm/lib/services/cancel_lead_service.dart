import 'dart:io';
import 'package:http/http.dart' as http;

class CancelLeadService {
  static const String baseUrl = "https://ruralrisk.in/api";

  Future<http.StreamedResponse> cancelLead({
    required String token,
    required String leadId,
    required String leadType,
    required String reason,
    String? otherReason,
    List<File>? images,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/field-worker/cancel-lead"),
    );

    request.headers.addAll({"Authorization": "Bearer $token"});

    request.fields["leadId"] = leadId;
    request.fields["leadType"] = leadType;
    request.fields["reason"] = reason;

    if (otherReason != null && otherReason.trim().isNotEmpty) {
      request.fields["otherReason"] = otherReason.trim();
    }

    // Multiple images
    if (images != null && images.isNotEmpty) {
      for (final image in images) {
        request.files.add(
          await http.MultipartFile.fromPath("cancellationImages", image.path),
        );
      }
    }

    print("======= UNIVERSAL CANCEL API =======");
    print("leadId => $leadId");
    print("leadType => $leadType");
    print("reason => $reason");
    print("otherReason => $otherReason");
    print("images count => ${images?.length ?? 0}");

    return await request.send();
  }
}
