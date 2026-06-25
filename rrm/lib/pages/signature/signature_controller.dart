// signature_controller.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:signature/signature.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/signature_service.dart';

class SignatureControllerX extends GetxController {
  final AppController appController = Get.find();

  final SignatureService _signatureService = SignatureService();
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

  Future<void> saveSignatures({
    required String tagNo,
    required String leadId,
    required String leadType,
    required String folderId,
  }) async {
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

      final token = appController.token.value;

      final response = await _signatureService.uploadSignatures(
        token: token,
        leadId: leadId,
        leadType: leadType,
        folderId: folderId,
        customerSignature: customerFile,
        fieldWorkerSignature: workerFile,
      );

      final responseBody = await response.stream.bytesToString();

      debugPrint("========== SIGNATURE API RESPONSE ==========");
      debugPrint("STATUS : ${response.statusCode}");
      debugPrint("BODY : $responseBody");
      debugPrint("===========================================");
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("SIGNATURE UPLOAD SUCCESS");

        Get.offNamed(routefarmerdetailspage);

        return;
      }

      throw Exception(responseBody);
    } catch (e) {
      debugPrint("========== SIGNATURE ERROR ==========");
      debugPrint(e.toString());
      debugPrint("====================================");

      if (Get.context != null) {
        Get.snackbar(
          "Error",
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
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
