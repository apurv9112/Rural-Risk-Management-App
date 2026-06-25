import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class FarmerDetailsController extends GetxController {
  ScreenshotController screenshotController = ScreenshotController();

  // screen shot

  Future<void> shareScreenshot() async {
    Get.dialog(
      Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 60,
        ),
      ),
      barrierColor: Colors.black45,
      barrierDismissible: false,
    );
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/farmer_screenshot.png';

      final image = await screenshotController.capture();

      if (image == null) return;

      final file = File(filePath);
      await file.writeAsBytes(image);

      await Share.shareXFiles([XFile(filePath)], text: "Farmer Details");
    } catch (e) {
      // print("Screenshot error: $e");
    }
  }
}
