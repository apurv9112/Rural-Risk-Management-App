import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TaggingdataController extends GetxController {
  //tagging data screen
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilenumbercontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController villegcontroller = TextEditingController();
  TextEditingController talukcontroller = TextEditingController();
  TextEditingController districcontroller = TextEditingController();
  TextEditingController banknamecontroller = TextEditingController();
  TextEditingController branchcontroller = TextEditingController();
  TextEditingController loanacnocontroller = TextEditingController();
  TextEditingController insurancecontroller = TextEditingController();
  TextEditingController buffalocountcontroller = TextEditingController();
  TextEditingController cowcountcontroller = TextEditingController();
  TextEditingController buffalomoneycontroller = TextEditingController();
  TextEditingController cowmoneycontroller = TextEditingController();
  TextEditingController dateofdeathcontroller = TextEditingController();
  TextEditingController timeofdeathcontroller = TextEditingController();

  /// temp exe

  bool? cowreadOnly = false;
  bool? buffaloreadOnly = false;
  dynamic data;
  String? ischangepage = "ischangepage";
  String? retagging = "retagging";
  bool? manualtagging = false;
  String? selectedReason;

  final List<String> imageUrls = [
    'asset/Tagging_Sample/100779925870a.jpg',
    'asset/Tagging_Sample/100779925870b.jpg',
    'asset/Tagging_Sample/100779925870c.jpg',
    'asset/Tagging_Sample/100779925870d.jpg',
  ];

  final List<String> taggingreasons = [
    "Not Purchased",
    "Unhealthy Cattle",
    "Unproductive Cattle",
    "Under Value Cattle",
    "Insured Not Cooperating",
    "Insured Not Available",
    "Other",
  ];
  final List<String> retaggingreasons = [
    "Cattle Not Matching",
    "False Request",
    "Cattle Sold Out",
    "Other",
  ];
  final List<String> claimreasons = [
    "Cattle Alive",
    "False Intimation",
    "Cattle Discarded",
    "Other",
  ];
  // date picker
  Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());

  void pickDate(BuildContext context, {required controller}) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? today,
      firstDate: DateTime(1900), // 🎯 any reasonable past start date
      lastDate: today, // ✅ Disallow future dates

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedDate.value = picked;
      controller.dateofdeathcontroller.text = DateFormat(
        'yyyy-MM-dd',
      ).format(picked);
      controller.update();
      print("Formatted date: ${controller.dateofdeathcontroller.text}");
    }
  }

  // time picker
  Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(TimeOfDay.now());

  void pickTime(BuildContext context, {required controller}) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.selectedTime.value ?? now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green, // ✅ Clock dial + OK/Cancel buttons
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedTime.value = picked;
      timeofdeathcontroller.text = picked.format(context);
      update();
      print("Selected Time: ${picked.format(context)}");
    }
  }

  Rx<File?> selectedOther1 = Rx<File?>(null);
  Rx<File?> selectedOther2 = Rx<File?>(null);
  Rx<File?> selectedOther3 = Rx<File?>(null);
  int? isimage = 0;
  final ImagePicker _picker = ImagePicker();

  //image  picker
  void pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      isimage == 1
          ? selectedOther1.value = File(pickedFile.path)
          : isimage == 2
          ? selectedOther2.value = File(pickedFile.path)
          : isimage == 3
          ? selectedOther3.value = File(pickedFile.path)
          : null;
      print("controllerimage::::$isimage");
      print("object  ::  ${selectedOther1.value}");
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
          ? selectedOther1.value = File(result.files.single.path!)
          : isimage == 2
          ? selectedOther2.value = File(result.files.single.path!)
          : isimage == 3
          ? selectedOther3.value = File(result.files.single.path!)
          : null;
      print("controllerimage::::$isimage");
    }
    update();
  }
}
