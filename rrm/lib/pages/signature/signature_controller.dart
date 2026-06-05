// signature_controller.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:signature/signature.dart';

class SignatureControllerX extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<Uint8List?> customerSignatureBytes = Rx<Uint8List?>(null);

  Rx<Uint8List?> workerSignatureBytes = Rx<Uint8List?>(null);
  final customerSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final workerSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  RxBool isSaving = false.obs;

  Future<void> saveSignatures({required String tagNo}) async {
    try {
      if (customerSignatureController.isEmpty) {
        Get.snackbar(
          "Required",
          "Customer signature required",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (workerSignatureController.isEmpty) {
        Get.snackbar(
          "Required",
          "Field worker signature required",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isSaving.value = true;

      final Uint8List? customerBytes = await customerSignatureController
          .toPngBytes();

      final Uint8List? workerBytes = await workerSignatureController
          .toPngBytes();

      final dir = await getApplicationDocumentsDirectory();

      final customerFile = File("${dir.path}/${tagNo}_customer_sign.png");

      final workerFile = File("${dir.path}/${tagNo}_worker_sign.png");

      await customerFile.writeAsBytes(customerBytes!);
      await workerFile.writeAsBytes(workerBytes!);

      debugPrint("Customer Sign Saved => ${customerFile.path}");
      debugPrint("Worker Sign Saved => ${workerFile.path}");

      Get.snackbar(
        "Success",
        "Signatures Saved Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      Get.offNamed(routefarmerdetailspage);

      // upload page open karvu hoy to ahi navigation muki sakay
      // Get.to(() => UploadPage());
    } catch (e) {
      debugPrint(e.toString());

      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    customerSignatureController.dispose();
    workerSignatureController.dispose();
    super.onClose();
  }
}
