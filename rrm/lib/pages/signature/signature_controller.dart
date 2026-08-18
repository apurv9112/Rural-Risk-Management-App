// signature_controller.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  Map<String, dynamic> taggingData = {};
  Map<String, dynamic> retaggingData = {};
  Map<String, dynamic> claimData = {};
  Map<String, dynamic> manualTaggingData = {};
  String dateOfDeath = "";
  String timeOfDeath = "";

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    final currentLeadType = (args["leadType"] ?? "").toString().toLowerCase();

    debugPrint("========== SIGNATURE INIT ==========");
    debugPrint("leadType: $currentLeadType");
    debugPrint("ALL ARGUMENTS: $args");
    debugPrint("====================================");

    // =========================
    // TAGGING
    // =========================
    if (currentLeadType == "tagging") {
      final data = args["taggingData"];

      if (data is Map && data.isNotEmpty) {
        taggingData = Map<String, dynamic>.from(data);
      } else if (args["tagging"] is Map &&
          (args["tagging"] as Map).isNotEmpty) {
        taggingData = Map<String, dynamic>.from(args["tagging"]);
      } else {
        taggingData = {};
      }
    } else {
      taggingData = {};
    }

    // =========================
    // RETAGGING
    // =========================
    if (currentLeadType == "retagging") {
      final data = args["retaggingData"];

      if (data is Map && data.isNotEmpty) {
        retaggingData = Map<String, dynamic>.from(data);
      } else if (args["retagging"] is Map &&
          (args["retagging"] as Map).isNotEmpty) {
        retaggingData = Map<String, dynamic>.from(args["retagging"]);
      } else {
        retaggingData = {};
      }
    } else {
      retaggingData = {};
    }

    // =========================
    // CLAIM
    // =========================
    if (currentLeadType == "claim") {
      final data = args["claimData"];

      if (data is Map && data.isNotEmpty) {
        claimData = Map<String, dynamic>.from(data);
      } else {
        claimData = {};
      }
    } else {
      claimData = {};
    }

    // =========================
    // MANUAL TAGGING
    // =========================
    if (currentLeadType == "manualtagging") {
      final data = args["manualTaggingData"];

      if (data is Map && data.isNotEmpty) {
        manualTaggingData = Map<String, dynamic>.from(data);
      } else if (args["manualtagging"] is Map &&
          (args["manualtagging"] as Map).isNotEmpty) {
        manualTaggingData = Map<String, dynamic>.from(args["manualtagging"]);
      } else {
        manualTaggingData = {};
      }
    } else {
      manualTaggingData = {};
    }

    // =========================
    // CLAIM DATE / TIME
    // =========================
    dateOfDeath = args["dateOfDeath"]?.toString() ?? "";

    timeOfDeath = args["timeOfDeath"]?.toString() ?? "";

    // =========================
    // DEBUG
    // =========================
    debugPrint("========== SIGNATURE DATA ==========");
    debugPrint("leadType: $currentLeadType");
    debugPrint("taggingData: $taggingData");
    debugPrint("retaggingData: $retaggingData");
    debugPrint("claimData: $claimData");
    debugPrint("manualTaggingData: $manualTaggingData");
    debugPrint("dateOfDeath: $dateOfDeath");
    debugPrint("timeOfDeath: $timeOfDeath");
    debugPrint("====================================");

    appController.loadUserData();

    loadWorkerSignature();
  }

  final customerSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  /// ===============================
  /// WORKER SIGNATURE
  /// ===============================

  Rx<File?> workerSignatureFile = Rx<File?>(null);

  final workerSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final ImagePicker imagePicker = ImagePicker();

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
          "Worker Signature",
          "Please create or upload your signature.",
          backgroundColor: Colors.orange,
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

      debugPrint("========== UPLOAD ==========");
      debugPrint("Customer : ${customerFile.path}");
      debugPrint("Worker   : ${workerFile.path}");
      debugPrint("============================");

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

        // Get.offNamed(
        //   routefarmerdetailspage,
        //   arguments: {
        //     "leadId": leadId,
        //     "leadType": leadType, // tagging / retagging / claim
        //   },
        // );

        print("========== SIGNATURE → FARMER DETAILS ==========");
        print("taggingData: $taggingData");
        print("retaggingData: $retaggingData");
        print("claimData: $claimData");
        print("manualTaggingData: $manualTaggingData");
        print("leadId: $leadId");
        print("leadType: $leadType");
        print("=================================================");
        Get.offNamed(
          routefarmerdetailspage,
          arguments: {
            // =========================
            // LEAD INFORMATION
            // =========================
            "leadId": leadId,
            "leadType": leadType,

            // =========================
            // REPORT DATA
            // =========================
            "taggingData": taggingData,
            "retaggingData": retaggingData,
            "claimData": claimData,
            "manualTaggingData": manualTaggingData,

            // =========================
            // CLAIM DATE / TIME
            // =========================
            "dateOfDeath": dateOfDeath,
            "timeOfDeath": timeOfDeath,

            // =========================
            // EXISTING
            // =========================
            "ischangepage": Get.arguments?["ischangepage"],
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

  Future<void> loadWorkerSignature() async {
    try {
      final file = await getWorkerSignatureFile();

      if (await file.exists()) {
        workerSignatureFile.value = file;

        debugPrint("WORKER SIGNATURE LOADED");
        debugPrint(file.path);
      } else {
        workerSignatureFile.value = null;

        debugPrint("WORKER SIGNATURE NOT FOUND");
      }

      update();
    } catch (e) {
      debugPrint("LOAD WORKER SIGNATURE ERROR => $e");
    }
  }

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

  Future<void> saveWorkerSignature(Uint8List bytes) async {
    try {
      final file = await getWorkerSignatureFile();

      await file.writeAsBytes(bytes, flush: true);

      workerSignatureFile.value = file;

      update();

      debugPrint("WORKER SIGNATURE SAVED");
      debugPrint(file.path);
    } catch (e) {
      debugPrint("SAVE WORKER SIGNATURE ERROR => $e");
    }
  }

  Future<void> deleteWorkerSignature() async {
    try {
      final file = await getWorkerSignatureFile();

      if (await file.exists()) {
        await file.delete();
      }

      workerSignatureController.clear();

      workerSignatureFile.value = null;

      update();

      debugPrint("WORKER SIGNATURE DELETED");
    } catch (e) {
      debugPrint("DELETE SIGNATURE ERROR => $e");
    }
  }

  Future<void> pickWorkerSignature({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);

      final Uint8List bytes = await file.readAsBytes();

      await saveWorkerSignature(bytes);

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Worker Signature Updated"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("PICK WORKER SIGNATURE ERROR => $e");
    }
  }

  Future<void> saveWorkerSignatureFromCanvas() async {
    try {
      if (workerSignatureController.isEmpty) return;

      final Uint8List? bytes = await workerSignatureController.toPngBytes();

      if (bytes == null) return;

      await saveWorkerSignature(bytes);

      workerSignatureController.clear();
    } catch (e) {
      debugPrint("DRAW SIGNATURE ERROR => $e");
    }
  }

  @override
  void onClose() {
    customerSignatureController.dispose();
    super.onClose();
  }
}
