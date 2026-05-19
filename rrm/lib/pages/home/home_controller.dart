// import 'dart:io';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:rrm/controller.dart';
// import 'package:signature/signature.dart';

// class HomeController extends GetxController {
//   String? retagging = "retagging";

//   AppController appController = Get.find();

//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   /// SIGNATURE CONTROLLER
//   SignatureController signatureController = SignatureController(
//     penStrokeWidth: 3,
//     penColor: Colors.black,
//     exportBackgroundColor: Colors.white,
//   );

//   @override
//   void onInit() {
//     super.onInit();

//     appController.loadUserData();
//   }

//   /// SAVE SIGNATURE
//   Future<void> saveSignature() async {
//     try {
//       if (signatureController.isEmpty) {
//         Get.snackbar("Error", "Please Draw Signature First");
//         return;
//       }

//       final ui.Image? image = await signatureController.toImage();

//       if (image == null) return;

//       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

//       final pngBytes = byteData!.buffer.asUint8List();

//       final directory = await getApplicationDocumentsDirectory();

//       final filePath = '${directory.path}/signature.png';

//       final file = File(filePath);

//       await file.writeAsBytes(pngBytes);

//       print("SIGNATURE PATH ::: $filePath");
//     } catch (e) {
//       print("SAVE SIGNATURE ERROR ::: $e");
//     }
//   }

//   @override
//   void onClose() {
//     signatureController.dispose();
//     super.onClose();
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rrm/controller.dart';
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

    /// LOAD SAVED SIGNATURE
    loadSavedSignature();
  }

  /// SAVE SIGNATURE
  /// SAVE SIGNATURE
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

      Uint8List pngBytes = byteData!.buffer.asUint8List();

      /// APP HIDDEN STORAGE
      final directory = await getExternalStorageDirectory();

      if (directory == null) return;

      /// SIGNATURE FOLDER
      final folder = Directory("${directory.path}/signatures");

      /// CREATE FOLDER
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      /// FILE NAME USING MOBILE NUMBER
      final filePath = "${folder.path}/${appController.mobileNumber.value}.png";

      final file = File(filePath);

      /// SAVE FILE
      await file.writeAsBytes(pngBytes);

      /// SAVE PATH
      signaturePath.value = filePath;

      print("SIGNATURE SAVED ::: $filePath");

      update();

      /// SUCCESS MESSAGE
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Signature Saved Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("SAVE SIGNATURE ERROR ::: $e");
    }
  }

  /// LOAD SAVED SIGNATURE
  Future<void> loadSavedSignature() async {
    try {
      final directory = await getExternalStorageDirectory();

      if (directory == null) return;

      final filePath =
          "${directory.path}/signatures/${appController.mobileNumber.value}.png";

      final file = File(filePath);

      if (await file.exists()) {
        signaturePath.value = filePath;

        print("SIGNATURE FOUND ::: $filePath");

        update();
      }
    } catch (e) {
      print("LOAD SIGNATURE ERROR ::: $e");
    }
  }

  /// CLEAR SIGNATURE
  Future<void> clearSignature() async {
    try {
      signatureController.clear();

      if (signaturePath.value.isNotEmpty) {
        final file = File(signaturePath.value);

        if (await file.exists()) {
          await file.delete();
        }

        signaturePath.value = "";

        update();
      }
    } catch (e) {
      print("CLEAR SIGNATURE ERROR ::: $e");
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

      File file = File(pickedFile.path);

      /// REMOVE BACKGROUND
      Uint8List pngBytes = await removeBackground(file);

      /// STORAGE
      final directory = await getExternalStorageDirectory();

      if (directory == null) return;

      final folder = Directory("${directory.path}/signatures");

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final filePath = "${folder.path}/${appController.mobileNumber.value}.png";

      final saveFile = File(filePath);

      await saveFile.writeAsBytes(pngBytes);

      signaturePath.value = filePath;

      update();

      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text("Signature Uploaded")));
      }
      update();
    } catch (e) {
      print("PICK SIGNATURE ERROR ::: $e");
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
}
