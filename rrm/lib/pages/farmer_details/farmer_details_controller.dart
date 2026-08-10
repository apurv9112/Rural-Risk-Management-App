import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/farmer_services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class FarmerDetailsController extends GetxController {
  final FarmerReportService _service = FarmerReportService();
  AppController appController = Get.find();
  ScreenshotController screenshotController = ScreenshotController();

  Map<String, dynamic> report = {};

  bool isLoading = true;

  String type = "";

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    debugPrint("Arguments : $args");

    getReport(leadId: args["leadId"], leadType: args["leadType"]);

    type = args["leadType"];
  }

  Future<void> getReport({
    required String leadId,
    required String leadType,
  }) async {
    try {
      report = await _service.getReport(leadId: leadId, leadType: leadType);
    } catch (e) {
      debugPrint("Farmer Report Error: $e");
      report = {};
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> shareScreenshot() async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/farmer_screenshot.png';

      final image = await screenshotController.capture();

      if (image == null) return;

      final file = File(filePath);
      await file.writeAsBytes(image);

      await Share.shareXFiles([
        XFile(filePath),
      ], text: "Pera-Wet - ${appController.userName.value}");
    } catch (e) {
      // print("Screenshot error: $e");
    }
  }
}
