import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/cancel_lead_service.dart';
import 'package:rrm/services/tagging_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../routes/common/common_app_pages.dart';

class TaggingdataController extends GetxController {
  final AppController _appController = Get.find();
  final TaggingService _taggingService = TaggingService();
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
  TextEditingController goatmoneycontroller = TextEditingController();
  TextEditingController sheepmoneycontroller = TextEditingController();
  TextEditingController sheepcountcontroller = TextEditingController();
  TextEditingController goatcontroller = TextEditingController();
  TextEditingController dateofdeathcontroller = TextEditingController();
  TextEditingController timeofdeathcontroller = TextEditingController();
  final FocusNode dateOfDeathFocusNode = FocusNode();
  final FocusNode timeOfDeathFocusNode = FocusNode();
  bool showDateError = false;
  bool showTimeError = false;
  String? species;
  String? tagnumberclaim;
  bool? cowreadOnly = false;
  bool? buffaloreadOnly = false;
  bool? goatoreadOnly = false;
  bool? sheepreadOnly = false;
  dynamic data;
  String? ischangepage;
  String? retagging;
  bool? manualtagging = false;
  String? selectedReasonDropdown;
  bool _fieldsInitialized = false;
  List<Uint8List> imageBytesList = [];
  final ScrollController imageScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    if (manualtagging == true) {
      loadInsuranceCompanies();
    }
  }

  void setInitialData(Map<String, dynamic> args) {
    if (data != null) return;

    manualtagging = args["manualtagging"] ?? false;

    if (manualtagging == true) {
      data = Map<String, dynamic>.from({
        "ownerName": "",
        "mobileNo": "",
        "address": "",
        "village": "",
        "taluko": "",
        "district": "",
        "bankName": "",
        "branchOfBank": "",
        "loanAccountNo": "",
        "insuranceCompanyName": "",
        "numberOfBuffalo": "",
        "numberOfCow": "",
        "sumInsuredBuffalo": "",
        "sumInsuredCow": "",
      });
    } else {
      data = args["tagging"] ?? args["retagging"] ?? args["claim"];
    }
    if (manualtagging == true) {
      loadInsuranceCompanies();
    }
  }

  void initFieldsFromData(Map<String, dynamic> dataMap, BuildContext context) {
    if (_fieldsInitialized) return;
    _fieldsInitialized = true;

    namecontroller.text = (dataMap["ownerName"] ?? '').toString();
    mobilenumbercontroller.text = (dataMap["mobileNo"] ?? '').toString();
    addresscontroller.text = (dataMap["address"] ?? '').toString();
    villegcontroller.text = (dataMap["village"] ?? '').toString();
    talukcontroller.text = (dataMap["taluko"] ?? '').toString();
    districcontroller.text = (dataMap["district"] ?? '').toString();
    banknamecontroller.text = (dataMap["bankName"] ?? '').toString();
    branchcontroller.text = (dataMap["branchOfBank"] ?? '').toString();
    loanacnocontroller.text = (dataMap["loanAccountNo"] ?? '').toString();
    insurancecontroller.text = (dataMap["insuranceCompanyName"] ?? '')
        .toString();
    buffalocountcontroller.text =
        _formatNumber(dataMap["numberOfBuffalo"]).isEmpty
        ? "-"
        : _formatNumber(dataMap["numberOfBuffalo"]);

    cowcountcontroller.text = _formatNumber(dataMap["numberOfCow"]).isEmpty
        ? "-"
        : _formatNumber(dataMap["numberOfCow"]);

    goatcontroller.text = _formatNumber(dataMap["numberOfGoat"]).isEmpty
        ? "-"
        : _formatNumber(dataMap["numberOfGoat"]);

    sheepcountcontroller.text = _formatNumber(dataMap["numberOfSheep"]).isEmpty
        ? "-"
        : _formatNumber(dataMap["numberOfSheep"]);

    buffalomoneycontroller.text =
        _formatNumber(dataMap["sumInsuredBuffalo"]).isEmpty
        ? "-"
        : _formatNumber(dataMap["sumInsuredBuffalo"]);

    cowmoneycontroller.text = _formatNumber(dataMap["sumInsuredCow"]).isEmpty
        ? "-"
        : _formatNumber(dataMap["sumInsuredCow"]);

    goatmoneycontroller.text = _formatNumber(dataMap["sumInsuredGoat"]).isEmpty
        ? "-"
        : _formatNumber(dataMap["sumInsuredGoat"]);

    sheepmoneycontroller.text =
        _formatNumber(dataMap["sumInsuredSheep"]).isEmpty
        ? "-"
        : _formatNumber(dataMap["sumInsuredSheep"]);

    species = dataMap["species"];
    tagnumberclaim = dataMap["tagNumber"] ?? dataMap["oldTagNumber"];
    dateofdeathcontroller.text =
        dataMap["dateOfDeath"] != null &&
            dataMap["dateOfDeath"].toString().isNotEmpty
        ? dataMap["dateOfDeath"].toString()
        : '';
    timeofdeathcontroller.text =
        dataMap["timeOfDeath"] != null &&
            dataMap["timeOfDeath"].toString().isNotEmpty
        ? dataMap["timeOfDeath"].toString()
        : '';
    final images = dataMap["images"];

    if (images != null && images is List) {
      imageBytesList = images.map<Uint8List>((img) {
        final base64Str = img.toString().split(',').last;
        return base64Decode(base64Str);
      }).toList();
    } else {
      imageBytesList = [];
    }
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '';
    if (value is num && value == 0) return '';
    return value.toString();
  }

  void syncDataFromControllers() {
    print("===== MANUAL DEBUG =====");
    print(data.runtimeType);
    print(data);

    if (data is Map) {
      (data as Map).forEach((k, v) {
        print("$k (${k.runtimeType}) => $v (${v.runtimeType})");
      });
    }
    if (data is Map<String, dynamic>) {
      final map = data as Map<String, dynamic>;
      final buffaloCount = int.tryParse(buffalocountcontroller.text.trim());
      final cowCount = int.tryParse(cowcountcontroller.text.trim());
      final buffaloSI = double.tryParse(buffalomoneycontroller.text.trim());
      final cowSI = double.tryParse(cowmoneycontroller.text.trim());
      if (buffaloCount != null) map["numberOfBuffalo"] = buffaloCount;
      if (cowCount != null) map["numberOfCow"] = cowCount;
      if (buffaloSI != null) map["sumInsuredBuffalo"] = buffaloSI;
      if (cowSI != null) map["sumInsuredCow"] = cowSI;

      if (retagging != null) {
        map["newTagNumber"] = timeofdeathcontroller.text.trim();
        map["dateOfReTagging"] = dateofdeathcontroller.text.trim();
      }
    }
  }

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
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

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
      controller.showDateError = false;
      controller.update();
      // print("Formatted date: ${controller.dateofdeathcontroller.text}");
    }
  }

  // time picker
  Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

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

    if (!context.mounted) return;

    if (picked != null) {
      selectedTime.value = picked;
      timeofdeathcontroller.text = picked.format(context);
      showTimeError = false;
      update();
      // print("Selected Time: ${picked.format(context)}");
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
      // print("controllerimage::::$isimage");
      // print("object  ::  ${selectedOther1.value}");
    }
    // update();
    update(['cancelDialog']);
  }

  void pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      isimage == 1
          ? selectedOther1.value = File(image.path)
          : isimage == 2
          ? selectedOther2.value = File(image.path)
          : isimage == 3
          ? selectedOther3.value = File(image.path)
          : null;
    }
    // update();
    update(['cancelDialog']);
  }

  Future<bool> createManualLead() async {
    final token = _appController.token.value;

    if (token.isEmpty) {
      debugPrint("Token not found");
      return false;
    }

    final int buffaloCount =
        int.tryParse(buffalocountcontroller.text.trim()) ?? 0;

    final int cowCount = int.tryParse(cowcountcontroller.text.trim()) ?? 0;

    final int goatCount = int.tryParse(goatcontroller.text.trim()) ?? 0;

    final int sheepCount = int.tryParse(sheepcountcontroller.text.trim()) ?? 0;

    final body = <String, dynamic>{
      "leadType": "tagging",

      "ownerName": namecontroller.text.trim(),
      "mobileNo": mobilenumbercontroller.text.trim(),
      "address": addresscontroller.text.trim(),
      "village": villegcontroller.text.trim(),
      "taluko": talukcontroller.text.trim(),
      "district": districcontroller.text.trim(),

      "state": "",
      "pinCode": "",
      "insuranceCompanyId": data["insuranceCompanyId"] ?? "",

      "insuranceCompanyName": insurancecontroller.text.trim(),
      "bankName": banknamecontroller.text.trim(),

      "branchOfBank": branchcontroller.text.trim(),
      "loanAccountNo": loanacnocontroller.text.trim(),

      "aadharFront": "",

      "cattle": [
        {
          "tagNumber": "",
          "species": species ?? "",
          "breed": "",
          "bodyColor": "",
          "cattleAge": "",
          "milkPerDayLtr": 0,

          "marketValue": 0,
          "taggingDate": "",
          "headPoseImage": "",
          "earTagImage": "",
        },
      ],
      "sumInsuredCow": cowmoneycontroller.text.trim(),
      "sumInsuredBuffalo": buffalomoneycontroller.text.trim(),
      "sumInsuredGoat": goatmoneycontroller.text.trim(),
      "sumInsuredSheep": sheepmoneycontroller.text.trim(),

      "numberOfCow": cowCount,
      "numberOfBuffalo": buffaloCount,
      "numberOfGoat": goatCount,
      "numberOfSheep": sheepCount,
    };

    try {
      final response = await _taggingService.createManualLead(
        token: token,
        body: body,
      );

      debugPrint("Manual Lead Status => ${response.statusCode}");
      debugPrint("Manual Lead Response => ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }

      final responseData = jsonDecode(response.body);

      final leadId =
          responseData["data"]?["leadId"] ??
          responseData["data"]?["_id"] ??
          responseData["leadId"] ??
          responseData["_id"];

      if (leadId != null) {
        data = {
          "id": leadId.toString(),
          "ownerName": namecontroller.text.trim(),
          "mobileNo": mobilenumbercontroller.text.trim(),
          "address": addresscontroller.text.trim(),
          "village": villegcontroller.text.trim(),
          "taluko": talukcontroller.text.trim(),
          "district": districcontroller.text.trim(),
          "bankName": banknamecontroller.text.trim(),
          "branchOfBank": branchcontroller.text.trim(),
          "loanAccountNo": loanacnocontroller.text.trim(),
          "insuranceCompanyName": insurancecontroller.text.trim(),
          "numberOfCow": cowCount,
          "numberOfBuffalo": buffaloCount,
          "numberOfGoat": goatCount,
          "numberOfSheep": sheepCount,
          "sumInsuredCow": cowmoneycontroller.text.trim(),
          "sumInsuredBuffalo": buffalomoneycontroller.text.trim(),
          "sumInsuredGoat": goatmoneycontroller.text.trim(),
          "sumInsuredSheep": sheepmoneycontroller.text.trim(),
        };

        debugPrint("===== MANUAL DATA =====");
        debugPrint(data.toString());
      }

      return true;
    } catch (e) {
      debugPrint("Manual Lead Error => $e");
      return false;
    }
  }

  // Udate lead API call //
  Future<void> saveLeadUpdates() async {
    if (data is! Map<String, dynamic>) return;
    final map = data as Map<String, dynamic>;
    final id = map["id"]?.toString();
    if (id == null || id.isEmpty) return;

    final token = _appController.token.value;
    if (token.isEmpty) return;

    syncDataFromControllers();

    final body = <String, dynamic>{};
    final buffaloCount = int.tryParse(buffalocountcontroller.text.trim());
    final cowCount = int.tryParse(cowcountcontroller.text.trim());
    final buffaloSI = double.tryParse(buffalomoneycontroller.text.trim());
    final cowSI = double.tryParse(cowmoneycontroller.text.trim());

    if (buffaloCount != null) body["numberOfBuffalo"] = buffaloCount;
    if (cowCount != null) body["numberOfCow"] = cowCount;
    if (buffaloSI != null) body["sumInsuredBuffalo"] = buffaloSI;
    if (cowSI != null) body["sumInsuredCow"] = cowSI;

    if (body.isEmpty) return;

    try {
      await _taggingService.updateLead(token: token, id: id, body: body);
      debugPrint("Lead $id updated with: $body");
    } catch (e) {
      debugPrint("Failed to update lead: $e");
    }
  }

  // cancel lead API call //
  // cancel lead API call //
  Future<void> cancelLeadUniversal() async {
    if (data is! Map<String, dynamic>) return;

    final map = data as Map<String, dynamic>;
    final id = map["id"]?.toString();

    if (id == null || id.isEmpty) {
      debugPrint("Invalid Lead ID");
      return;
    }

    final token = _appController.token.value;

    if (token.isEmpty) {
      debugPrint("Session expired");
      return;
    }

    if (selectedReasonDropdown == null) {
      debugPrint("Please select reason");
      return;
    }

    try {
      // ✅ ONLY ONE LOADER
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

      // ✅ Lead Type
      String leadType = "tagging";

      if (retagging != null) {
        leadType = "retagging";
      } else if (ischangepage != null) {
        leadType = "claim";
      }

      // ✅ Images List
      List<File> images = [];

      if (selectedOther1.value != null) {
        images.add(selectedOther1.value!);
      }

      if (selectedOther2.value != null) {
        images.add(selectedOther2.value!);
      }

      if (selectedOther3.value != null) {
        images.add(selectedOther3.value!);
      }

      final cancelService = CancelLeadService();
      final response = await cancelService.cancelLead(
        token: token,
        leadId: id,
        leadType: leadType,
        reason: selectedReasonDropdown!,
        otherReason: selectedReasonDropdown == "Other" ? "Custom Reason" : null,
        images: images,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to cancel lead");
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ CLOSE LOADER SAFELY
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.offAllNamed(
        routehomepage,
        arguments: {"success": "Lead cancelled successfully"},
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print("CANCEL ERROR => $e");

      // ❌ NO SNACKBAR HERE
      debugPrint("Something went wrong");
    }
  }

  List<Map<String, dynamic>> insuranceCompanies = [];

  String? selectedInsuranceValue;

  bool isInsuranceLoading = false;

  Future<void> loadInsuranceCompanies() async {
    try {
      isInsuranceLoading = true;
      update();

      final token = _appController.token.value;

      final companies = await _taggingService.getInsuranceCompanies(
        token: token,
      );

      debugPrint("===== INSURANCE API RESPONSE =====");
      debugPrint(companies.toString());

      insuranceCompanies = List<Map<String, dynamic>>.from(companies);

      debugPrint("===== INSURANCE LIST =====");
      debugPrint(insuranceCompanies.toString());

      isInsuranceLoading = false;
      update();
    } catch (e, stackTrace) {
      debugPrint("===== INSURANCE API ERROR =====");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      isInsuranceLoading = false;
      update();
    }
  }

  // manual tagging validation

  bool showOwnerError = false;
  bool showMobileError = false;
  bool showAddressError = false;
  bool showVillageError = false;
  bool showTalukoError = false;
  bool showDistrictError = false;
  bool showBankError = false;
  bool showBranchError = false;
  bool showInsuranceError = false;

  bool showSpeciesError = false;

  bool validateManualFields() {
    if (manualtagging != true) {
      return true;
    }

    showOwnerError = namecontroller.text.trim().isEmpty;
    showMobileError = mobilenumbercontroller.text.trim().isEmpty;
    showAddressError = addresscontroller.text.trim().isEmpty;
    showVillageError = villegcontroller.text.trim().isEmpty;
    showTalukoError = talukcontroller.text.trim().isEmpty;
    showDistrictError = districcontroller.text.trim().isEmpty;
    showBankError = banknamecontroller.text.trim().isEmpty;
    showBranchError = branchcontroller.text.trim().isEmpty;
    showInsuranceError = insurancecontroller.text.trim().isEmpty;

    update();

    return !(showOwnerError ||
        showMobileError ||
        showAddressError ||
        showVillageError ||
        showTalukoError ||
        showDistrictError ||
        showBankError ||
        showBranchError ||
        showInsuranceError);
  }

  // bool validateSpecies() {
  //   if (manualtagging != true) {
  //     return true;
  //   }

  //   final hasBuffalo =
  //       buffalocountcontroller.text.trim().isNotEmpty ||
  //       buffalomoneycontroller.text.trim().isNotEmpty;

  //   final hasCow =
  //       cowcountcontroller.text.trim().isNotEmpty ||
  //       cowmoneycontroller.text.trim().isNotEmpty;

  //   final hasGoat =
  //       goatcontroller.text.trim().isNotEmpty ||
  //       goatmoneycontroller.text.trim().isNotEmpty;

  //   final hasSheep =
  //       sheepcountcontroller.text.trim().isNotEmpty ||
  //       sheepmoneycontroller.text.trim().isNotEmpty;

  //   showSpeciesError = !(hasBuffalo || hasCow || hasGoat || hasSheep);

  //   update();

  //   return !showSpeciesError;
  // }

  bool showBuffaloError = false;
  bool showCowError = false;
  bool showGoatError = false;
  bool showSheepError = false;

  bool validateSpecies() {
    if (manualtagging != true) {
      return true;
    }

    final buffaloCount = buffalocountcontroller.text.trim();
    final buffaloAmount = buffalomoneycontroller.text.trim();

    final cowCount = cowcountcontroller.text.trim();
    final cowAmount = cowmoneycontroller.text.trim();

    final goatCount = goatcontroller.text.trim();
    final goatAmount = goatmoneycontroller.text.trim();

    final sheepCount = sheepcountcontroller.text.trim();
    final sheepAmount = sheepmoneycontroller.text.trim();

    final hasBuffalo = buffaloCount.isNotEmpty || buffaloAmount.isNotEmpty;

    final hasCow = cowCount.isNotEmpty || cowAmount.isNotEmpty;

    final hasGoat = goatCount.isNotEmpty || goatAmount.isNotEmpty;

    final hasSheep = sheepCount.isNotEmpty || sheepAmount.isNotEmpty;

    final hasAnySpecies = hasBuffalo || hasCow || hasGoat || hasSheep;

    showSpeciesError = !hasAnySpecies;

    showBuffaloError =
        showSpeciesError ||
        (hasBuffalo && (buffaloCount.isEmpty || buffaloAmount.isEmpty));

    showCowError =
        showSpeciesError || (hasCow && (cowCount.isEmpty || cowAmount.isEmpty));

    showGoatError =
        showSpeciesError ||
        (hasGoat && (goatCount.isEmpty || goatAmount.isEmpty));

    showSheepError =
        showSpeciesError ||
        (hasSheep && (sheepCount.isEmpty || sheepAmount.isEmpty));
    update();

    return hasAnySpecies &&
        !showBuffaloError &&
        !showCowError &&
        !showGoatError &&
        !showSheepError;
  }

  @override
  void onClose() {
    dateOfDeathFocusNode.dispose();
    timeOfDeathFocusNode.dispose();
    super.onClose();
  }
}
