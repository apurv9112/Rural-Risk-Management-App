import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rrm/controller.dart';
import 'package:signature/signature.dart';

class HomeController extends GetxController {
  String? retagging = "retagging";

  AppController appController = Get.find();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// SIGNATURE CONTROLLER
  SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void onInit() {
    super.onInit();

    appController.loadUserData();
  }

  /// SAVE SIGNATURE
  Future<void> saveSignature() async {
    try {
      if (signatureController.isEmpty) {
        Get.snackbar("Error", "Please Draw Signature First");
        return;
      }

      final ui.Image? image = await signatureController.toImage();

      if (image == null) return;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();

      final filePath = '${directory.path}/signature.png';

      final file = File(filePath);

      await file.writeAsBytes(pngBytes);

      print("SIGNATURE PATH ::: $filePath");
    } catch (e) {
      print("SAVE SIGNATURE ERROR ::: $e");
    }
  }

  @override
  void onClose() {
    signatureController.dispose();
    super.onClose();
  }
}
