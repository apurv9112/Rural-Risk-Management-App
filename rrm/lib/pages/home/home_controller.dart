import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:rrm/controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class HomeController extends GetxController {
  String? retagging = "retagging";

  AppController appController = Get.find();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// SIGNATURE FILE PATH
  RxString signaturePath = "".obs;

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

    loadSavedSignature();
  }

  /// ===============================
  /// PROFILE SIGNATURE DIRECTORY
  /// ===============================
  Future<Directory> getSignatureDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();

    final directory = Directory("${appDir.path}/RRM/Profile");

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  /// ===============================
  /// WORKER SIGNATURE FILE
  /// ===============================
  Future<File> getWorkerSignatureFile() async {
    final directory = await getSignatureDirectory();

    return File(
      "${directory.path}/${appController.mobileNumber.value}_worker_signature.png",
    );
  }

  /// SAVE PROFILE SIGNATURE
  /// ===============================
  Future<void> saveSignature() async {
    try {
      if (signatureController.isEmpty) {
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(content: Text("Please Draw Signature First")),
          );
        }
        return;
      }

      final ui.Image? image = await signatureController.toImage();

      if (image == null) return;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      /// Get Worker Signature File
      final File file = await getWorkerSignatureFile();

      /// Save Signature
      await file.writeAsBytes(pngBytes, flush: true);

      /// Update UI
      signaturePath.value = file.path;

      update();

      debugPrint("=================================");
      debugPrint("PROFILE SIGNATURE SAVED");
      debugPrint(file.path);
      debugPrint("=================================");

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Profile Signature Saved"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("SAVE SIGNATURE ERROR => $e");

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// ===============================
  /// LOAD SAVED SIGNATURE
  /// ===============================
  /// ===============================
  /// LOAD PROFILE SIGNATURE
  /// ===============================
  Future<void> loadSavedSignature() async {
    try {
      /// Get Worker Signature File
      final File file = await getWorkerSignatureFile();

      if (await file.exists()) {
        signaturePath.value = file.path;

        debugPrint("=================================");
        debugPrint("PROFILE SIGNATURE FOUND");
        debugPrint(file.path);
        debugPrint("=================================");
      } else {
        signaturePath.value = "";

        debugPrint("=================================");
        debugPrint("NO PROFILE SIGNATURE FOUND");
        debugPrint("=================================");
      }

      update();
    } catch (e) {
      debugPrint("LOAD SIGNATURE ERROR => $e");
    }
  }

  /// ===============================
  /// CLEAR SIGNATURE (SAFE)
  /// ===============================
  Future<void> clearSignature() async {
    try {
      /// Clear only current drawing
      signatureController.clear();

      /// Remove preview from UI
      signaturePath.value = "";

      update();

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Signature Cleared"),
            backgroundColor: Colors.orange,
          ),
        );
      }

      debugPrint("SIGNATURE PREVIEW CLEARED");
    } catch (e) {
      debugPrint("CLEAR SIGNATURE ERROR => $e");
    }
  }

  @override
  void onClose() {
    signatureController.dispose();

    super.onClose();
  }

  /////////////////////////
  /// PICK IMAGE FUNCTION //
  /////////////////////////

  Future<void> pickSignatureImage({required ImageSource source}) async {
    try {
      final picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile == null) return;

      final File imageFile = File(pickedFile.path);

      /// Remove Background
      final Uint8List pngBytes = await removeBackground(imageFile);

      /// Get Profile Signature File
      final File saveFile = await getWorkerSignatureFile();

      /// Save Signature
      await saveFile.writeAsBytes(pngBytes, flush: true);

      /// Update UI
      signaturePath.value = saveFile.path;

      update();

      debugPrint("=================================");
      debugPrint("PROFILE SIGNATURE IMAGE SAVED");
      debugPrint(saveFile.path);
      debugPrint("=================================");

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Profile Signature Updated"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("PICK SIGNATURE ERROR => $e");

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// REMOVE BACKGROUND FUNCTION ///

  Future<Uint8List> removeBackground(File file) async {
    final bytes = await file.readAsBytes();

    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Image not found");
    }

    /// AUTO ROTATE
    if (image.height > image.width) {
      image = img.copyRotate(image, angle: 90);
    }

    /// CONVERT TO GRAYSCALE
    image = img.grayscale(image);

    int minX = image.width;
    int minY = image.height;

    int maxX = 0;
    int maxY = 0;

    /// REMOVE WHITE BG
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        int value = pixel.r.toInt();

        /// KEEP DARK PIXELS
        if (value < 180) {
          minX = x < minX ? x : minX;
          minY = y < minY ? y : minY;

          maxX = x > maxX ? x : maxX;
          maxY = y > maxY ? y : maxY;
        } else {
          /// TRANSPARENT BG
          image.setPixelRgba(x, y, 255, 255, 255, 0);
        }
      }
    }

    /// CREATE CLEAN CANVAS
    img.Image finalImage = img.Image(width: 1000, height: 400);

    /// TRANSPARENT BG
    img.fill(finalImage, color: img.ColorRgba8(255, 255, 255, 0));

    /// RESIZE SIGNATURE
    img.Image resized = img.copyResize(image, height: 250);

    /// CENTER POSITION
    int offsetX = (finalImage.width - resized.width) ~/ 2;

    int offsetY = (finalImage.height - resized.height) ~/ 2;

    /// DRAW CENTER
    img.compositeImage(finalImage, resized, dstX: offsetX, dstY: offsetY);

    image = finalImage;

    /// RESIZE FOR CLEAN PREVIEW
    image = img.copyResize(image, width: 800);

    return Uint8List.fromList(img.encodePng(image));
  }

  Future<void> deleteSignature() async {
    try {
      final file = await getWorkerSignatureFile();

      if (await file.exists()) {
        await file.delete();
      }

      signatureController.clear();

      signaturePath.value = "";

      update();

      Get.snackbar("Success", "Signature Deleted Successfully");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
