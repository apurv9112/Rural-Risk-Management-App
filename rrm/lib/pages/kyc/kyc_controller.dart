import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/kyc_service.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/services/image_processing_service.dart';
import 'package:rrm/services/camera_service.dart';

import 'package:rrm/widgets/snackbar_widget.dart';
import 'package:rrm/core/storage/folder_manager.dart';

class KycController extends GetxController {
  final AppController appController = Get.find();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();

  dynamic data;
  String? ischangepage;
  String? retagging;

  String ownerName = '';
  String mobileNo = '';

  bool isSubmitting = false;

  // IMAGE STATES
  int? isimage = 0;

  Rx<File?> selectedAadharfront = Rx<File?>(null);
  Rx<File?> selectedAadharback = Rx<File?>(null);
  Rx<File?> selectedPanfront = Rx<File?>(null);
  Rx<File?> selectedbankdetails1 = Rx<File?>(null);
  Rx<File?> selectedbankdetails2 = Rx<File?>(null);

  Rx<File?> selectedOther1 = Rx<File?>(null);
  Rx<File?> selectedOther2 = Rx<File?>(null);
  Rx<File?> selectedOther3 = Rx<File?>(null);
  Rx<File?> selectedOther4 = Rx<File?>(null);
  Rx<File?> selectedOther5 = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();

    final args = (Get.arguments as Map<String, dynamic>?) ?? {};

    data = args["tagging"];
    ischangepage = args["ischangepage"];
    retagging = args["retagging"];

    final tagging = data as Map<String, dynamic>?;

    ownerName = (tagging?["ownerName"] ?? '').toString();
    mobileNo = (tagging?["mobileNo"] ?? '').toString();

    namecontroller.text = ownerName;
    mobilecontroller.text = mobileNo;

    debugPrint("KYC INIT → ID: ${data?["id"]}");
    debugPrint("Flow → ischangepage: $ischangepage, retagging: $retagging");

    // checkKycStatus();
  }

  // ================= IMAGE PICKER =================

  void pickFromCamera() async {
    final pickedFile = await CameraService.captureImage();

    if (pickedFile != null) {
      File file = File(pickedFile.path);

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
        file = await ImageProcessingService.processImage(file);
      } catch (e) {
        print("Image processing error: $e");
      }
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      switch (isimage) {
        case 1:
          selectedAadharfront.value = file;
          break;
        case 2:
          selectedAadharback.value = file;
          break;
        case 3:
          selectedPanfront.value = file;
          break;
        case 4:
          selectedbankdetails1.value = file;
          break;
        case 5:
          selectedbankdetails2.value = file;
          break;
        case 6:
          selectedOther5.value = file;
          break;
        case 7:
          selectedOther1.value = file;
          break;
        case 8:
          selectedOther2.value = file;
          break;
        case 9:
          selectedOther3.value = file;
          break;
        case 10:
          selectedOther4.value = file;
          break;
      }
    }
    update();
  }

  void pickFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File file = await FolderManager.moveFromCache(
        File(result.files.single.path!),
        workflow: 'temp',
      );

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
        file = await ImageProcessingService.processImage(file);
      } catch (e) {
        print("Image processing error: $e");
      }
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      switch (isimage) {
        case 1:
          selectedAadharfront.value = file;
          break;
        case 2:
          selectedAadharback.value = file;
          break;
        case 3:
          selectedPanfront.value = file;
          break;
        case 4:
          selectedbankdetails1.value = file;
          break;
        case 5:
          selectedbankdetails2.value = file;
          break;
        case 6:
          selectedOther5.value = file;
          break;
        case 7:
          selectedOther1.value = file;
          break;
        case 8:
          selectedOther2.value = file;
          break;
        case 9:
          selectedOther3.value = file;
          break;
        case 10:
          selectedOther4.value = file;
          break;
      }
    }
    update();
  }

  // ================= SAVE KYC =================

  Future<void> savekyc() async {
    if (isSubmitting) return;

    if (data == null || data["id"] == null) {
      showSnackBar("Data not found.", SNACK.FAILED);
      return;
    }

    final token = appController.token.value;

    if (token.isEmpty) {
      showSnackBar("Session expired.", SNACK.FAILED);
      return;
    }

    // ================= FILE LIST =================

    final List<File> uploadFiles = [];

    void addFile(File? file) {
      if (file != null) {
        uploadFiles.add(file);
      }
    }

    addFile(selectedAadharfront.value);
    addFile(selectedAadharback.value);
    addFile(selectedPanfront.value);
    addFile(selectedbankdetails1.value);
    addFile(selectedbankdetails2.value);
    addFile(selectedOther1.value);
    addFile(selectedOther2.value);
    addFile(selectedOther3.value);
    addFile(selectedOther4.value);
    addFile(selectedOther5.value);

    if (uploadFiles.isEmpty) {
      showSnackBar("Please Add at Least Two KYC Document.", SNACK.FAILED);
      return;
    }

    // ================= FLOW TYPE =================

    String leadType = "tagging";

    // RETAGGING FLOW
    if (retagging == "retagging") {
      leadType = "retagging";
    }
    // CLAIM FLOW
    else if (ischangepage != null) {
      leadType = "claim";
    }

    print("========== SAVE KYC DEBUG ==========");
    print("FLOW => $leadType");
    print("LEAD ID => ${data["id"]}");
    print("IS CHANGE PAGE => $ischangepage");
    print("RETAGGING => $retagging");
    print("FILES COUNT => ${uploadFiles.length}");
    print("===================================");

    // ================= LOADER =================

    isSubmitting = true;
    update();

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
      final kycService = KycService();
      final response = await kycService.uploadKyc(
        token: token,
        leadId: data["id"].toString(),
        leadType: leadType,
        files: uploadFiles,
      );

      if (response["statusCode"] != 200 && response["statusCode"] != 201) {
        throw Exception("Failed to upload KYC: ${response["body"]}");
      }

      await Future.delayed(const Duration(milliseconds: 500));

      showSnackBar("KYC Saved Successfully", SNACK.SUCCESS);

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.toNamed(
        routecattlepage,
        arguments: {
          "tagging": data,
          "ischangepage": ischangepage,
          "retagging": retagging,
          "customerName": namecontroller.text.trim(),
        },
      );
    } catch (e) {
      print("========== KYC ERROR ==========");
      print(e.toString());
      print("================================");

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      showSnackBar("Something went wrong", SNACK.FAILED);
      Get.toNamed(
        routecattlepage,
        arguments: {
          "tagging": data,
          "ischangepage": ischangepage,
          "retagging": retagging,
        },
      );
    } finally {
      isSubmitting = false;
      update();
    }
  }
}
