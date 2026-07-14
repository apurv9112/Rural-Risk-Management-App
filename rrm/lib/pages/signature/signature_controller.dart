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

  @override
  void onInit() {
    super.onInit();

    appController.loadUserData();

    loadWorkerSignature();
  }

  final customerSignatureController = SignatureController(
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

      if (workerSignatureFile.value == null) {
        Get.snackbar(
          "Required",
          "Please save your profile signature first.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isSaving.value = true;

      final Uint8List? customerBytes = await customerSignatureController
          .toPngBytes();

      final workerFile = workerSignatureFile.value!;

      final dir = await getApplicationDocumentsDirectory();

      final customerFile = File("${dir.path}/${tagNo}_customer_sign.png");

      await customerFile.writeAsBytes(customerBytes!);

      debugPrint("Customer Sign Saved => ${customerFile.path}");

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

        Get.offNamed(
          routefarmerdetailspage,
          arguments: {
            "leadId": leadId,
            "leadType": leadType, // tagging / retagging / claim
          },
        );

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

  /// ===============================
  /// PROFILE WORKER SIGNATURE FILE
  /// ===============================

  Rx<File?> workerSignatureFile = Rx<File?>(null);

  Future<Directory> getSignatureDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();

    final directory = Directory("${appDir.path}/RRM/Profile");

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future<File> getWorkerSignatureFile() async {
    final directory = await getSignatureDirectory();

    return File(
      "${directory.path}/${appController.mobileNumber.value}_worker_signature.png",
    );
  }

  Future<void> loadWorkerSignature() async {
    try {
      final file = await getWorkerSignatureFile();

      debugPrint("========== SIGNATURE ==========");
      debugPrint("Mobile : ${appController.mobileNumber.value}");
      debugPrint("Path   : ${file.path}");
      debugPrint("Exists : ${await file.exists()}");

      if (await file.exists()) {
        workerSignatureFile.value = file;

        debugPrint("LOADED");
      } else {
        workerSignatureFile.value = null;

        debugPrint("NOT FOUND");
      }

      debugPrint("===============================");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void onClose() {
    customerSignatureController.dispose();
    super.onClose();
  }
}
