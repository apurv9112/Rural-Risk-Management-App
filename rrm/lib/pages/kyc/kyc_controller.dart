import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/services/kyc_service.dart';
import 'package:rrm/services/tagging_service.dart';

class KycController extends GetxController {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();

  dynamic data;
  String? ischangepage;
  String? retagging;

  String ownerName = '';
  String mobileNo = '';

  final AppController appController = Get.find();
  final KycService _kycService = KycService();
  final TaggingService _taggingService = TaggingService();

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

  final ImagePicker _picker = ImagePicker();

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
  }

  // ================= IMAGE PICKER =================

  void pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

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
      File file = File(result.files.single.path!);

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
      showSnackBar("Tagging/Claim data not found.", SNACK.FAILED);
      return;
    }

    if (_allImagesEmpty()) {
      showSnackBar("Please add at least one KYC document.", SNACK.FAILED);
      return;
    }

    final token = appController.token.value;

    if (token.isEmpty) {
      showSnackBar("Session expired. Please login again.", SNACK.FAILED);
      return;
    }

    isSubmitting = true;
    update();

    Get.dialog(
      Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 60,
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final bool isTaggingFlow = ischangepage == null && retagging == null;

      debugPrint("FLOW TYPE → ${isTaggingFlow ? "TAGGING" : "CLAIM"}");
      debugPrint("SENDING ID → ${data["id"]}");

      if (isTaggingFlow) {
        final payloadData = await _buildImagePayload();

        final leadPayload = {...payloadData, "kycStatus": "Uploaded"};

        final resp = await _taggingService.updateLead(
          token: token,
          id: data["id"].toString(),
          body: leadPayload,
        );

        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};

        if (resp.statusCode >= 200 &&
            resp.statusCode < 300 &&
            decoded["status"] == "success") {
          Future.delayed(const Duration(milliseconds: 200), () {
            showSnackBar("KYC updated successfully.", SNACK.SUCCESS);
          });

          if (Get.isDialogOpen ?? false) Get.back();

          Get.offNamed(routecattlepage, arguments: {"tagging": data});
        } else {
          Future.delayed(const Duration(milliseconds: 200), () {
            showSnackBar(
              decoded["message"] ?? "Failed to update lead.",
              SNACK.FAILED,
            );
          });
        }
      }
    } catch (e) {
      debugPrint("ERROR → $e");
      showSnackBar("Error: ${e.toString()}", SNACK.FAILED);
    } finally {
      isSubmitting = false;
      if (Get.isDialogOpen ?? false) Get.back();
      update();
    }
  }
  // ================= HELPERS =================

  bool _allImagesEmpty() {
    return selectedAadharfront.value == null &&
        selectedAadharback.value == null &&
        selectedPanfront.value == null &&
        selectedbankdetails1.value == null &&
        selectedbankdetails2.value == null &&
        selectedOther1.value == null &&
        selectedOther2.value == null &&
        selectedOther3.value == null &&
        selectedOther4.value == null &&
        selectedOther5.value == null;
  }

  // Map<String, dynamic> _buildImagePayload() {
  //   final payload = <String, dynamic>{};

  //   void addFile(String key, File? file) {
  //     if (file == null) return;
  //     payload[key] = base64Encode(file.readAsBytesSync());
  //   }

  //   addFile("aadharFront", selectedAadharfront.value);
  //   addFile("aadharBack", selectedAadharback.value);
  //   addFile("panFront", selectedPanfront.value);
  //   addFile("bankDetailsPhoto1", selectedbankdetails1.value);
  //   addFile("bankDetailsPhoto2", selectedbankdetails2.value);
  //   addFile("otherImage1", selectedOther1.value);
  //   addFile("otherImage2", selectedOther2.value);
  //   addFile("otherImage3", selectedOther3.value);
  //   addFile("otherImage4", selectedOther4.value ?? selectedOther5.value);

  //   return payload;
  // }

  Future<Map<String, dynamic>> _buildImagePayload() async {
    final payload = <String, dynamic>{};

    Future<void> addFile(String key, File? file) async {
      if (file == null) return;

      try {
        final bytes = await file.readAsBytes(); // ✅ async (NO FREEZE)
        payload[key] = base64Encode(bytes);
      } catch (e) {
        debugPrint("Error reading file $key: $e");
      }
    }

    await addFile("aadharFront", selectedAadharfront.value);
    await addFile("aadharBack", selectedAadharback.value);
    await addFile("panFront", selectedPanfront.value);
    await addFile("bankDetailsPhoto1", selectedbankdetails1.value);
    await addFile("bankDetailsPhoto2", selectedbankdetails2.value);
    await addFile("otherImage1", selectedOther1.value);
    await addFile("otherImage2", selectedOther2.value);
    await addFile("otherImage3", selectedOther3.value);
    await addFile("otherImage4", selectedOther4.value ?? selectedOther5.value);

    return payload;
  }

  Map<String, dynamic> _buildLeadUpdatePayload(dynamic source) {
    if (source is! Map<String, dynamic>) return {};

    return {
      "ownerName": source["ownerName"],
      "mobileNo": source["mobileNo"],
      "address": source["address"],
      "village": source["village"],
      "taluko": source["taluko"],
      "district": source["district"],
      "bankName": source["bankName"],
      "branchOfBank": source["branchOfBank"],
      "loanAccountNo": source["loanAccountNo"],
      "insuranceCompanyName": source["insuranceCompanyName"],
      "kycStatus": "Completed",
    };
  }
}
