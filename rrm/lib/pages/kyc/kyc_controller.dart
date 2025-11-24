import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/routes/common/common_app_pages.dart';

class KycController extends GetxController {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  dynamic data;
  String? claimcattle = "claimcattle";
  String? ischangepage = "ischangepage";
  String? retagging = "retagging";

  // kyc screen

  int? isimage = 0;
  Rx<File?> selectedAadharfront = Rx<File?>(null);
  Rx<File?> selectedAadharback = Rx<File?>(null);
  Rx<File?> selectedbankdetails1 = Rx<File?>(null);
  Rx<File?> selectedbankdetails2 = Rx<File?>(null);
  Rx<File?> selectedPanfront = Rx<File?>(null);
  Rx<File?> selectedOther5 = Rx<File?>(null);
  Rx<File?> selectedOther1 = Rx<File?>(null);
  Rx<File?> selectedOther2 = Rx<File?>(null);
  Rx<File?> selectedOther3 = Rx<File?>(null);
  Rx<File?> selectedOther4 = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  //image  picker
  void pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      isimage == 1
          ? selectedAadharfront.value = File(pickedFile.path)
          : isimage == 2
          ? selectedAadharback.value = File(pickedFile.path)
          : isimage == 3
          ? selectedPanfront.value = File(pickedFile.path)
          : isimage == 4
          ? selectedbankdetails1.value = File(pickedFile.path)
          : isimage == 5
          ? selectedbankdetails2.value = File(pickedFile.path)
          : isimage == 6
          ? selectedOther5.value = File(pickedFile.path)
          : isimage == 7
          ? selectedOther1.value = File(pickedFile.path)
          : isimage == 8
          ? selectedOther2.value = File(pickedFile.path)
          : isimage == 9
          ? selectedOther3.value = File(pickedFile.path)
          : isimage == 10
          ? selectedOther4.value = File(pickedFile.path)
          : null;
      print("controllerimage::::$isimage");
      print("controllerimage::::${selectedAadharfront.value}");
      print("controllerimage11111111::::${selectedAadharback.value}");
    }
    update();
  }

  void pickMultipleFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false, // Only one for dropdown
    );
    if (result != null && result.files.single.path != null) {
      isimage == 1
          ? selectedAadharfront.value = File(result.files.single.path!)
          : isimage == 2
          ? selectedAadharback.value = File(result.files.single.path!)
          : isimage == 3
          ? selectedbankdetails1.value = File(result.files.single.path!)
          : isimage == 4
          ? selectedbankdetails2.value = File(result.files.single.path!)
          : isimage == 5
          ? selectedPanfront.value = File(result.files.single.path!)
          : isimage == 6
          ? selectedOther5.value = File(result.files.single.path!)
          : isimage == 7
          ? selectedOther1.value = File(result.files.single.path!)
          : isimage == 8
          ? selectedOther2.value = File(result.files.single.path!)
          : isimage == 9
          ? selectedOther3.value = File(result.files.single.path!)
          : isimage == 10
          ? selectedOther4.value = File(result.files.single.path!)
          : null;
      print("controllerimage::::$isimage");
    }
    update();
  }

  void savekyc() {
    if (selectedAadharfront.value != null ||
        selectedAadharback.value != null ||
        selectedbankdetails1.value != null) {
      Get.dialog(
        Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 60,
          ),
        ),
        barrierDismissible: false,
      );
      // Delay for 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        Get.back(); // close loading dialog
        Get.toNamed(
          routecattlepage,
          arguments: {"retagging": retagging, "ischangepage": ischangepage},
        );
      });

      update();
    }
    update();
  }
}
