import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rrm/services/base.dart';

class FarmerReportService {
  static const String baseUrl = baseAPIUrl;

  Future<Map<String, dynamic>> getReport({
    required String leadId,
    required String leadType,
  }) async {
    final url = "$baseUrl/field-worker/report/$leadType/$leadId";

    debugPrint("URL : $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );

    debugPrint("Status : ${response.statusCode}");
    debugPrint("Response : ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["status"] == "success") {
      return data["data"];
    }

    throw Exception(response.body);
  }
}
