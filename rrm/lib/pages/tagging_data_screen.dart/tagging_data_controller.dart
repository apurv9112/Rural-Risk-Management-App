import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/cancel_lead_service.dart';
// import 'package:rrm/services/claim_service.dart';
// import 'package:rrm/services/retagging_service.dart';
import 'package:rrm/services/tagging_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/data/repositories/lead_repository.dart';
import 'package:rrm/data/models/lead_model.dart';
import 'package:rrm/data/repositories/draft_repository.dart';


class TaggingdataController extends GetxController {
  final AppController _appController = Get.find();
  final TaggingService _taggingService = TaggingService();
  // final RetaggingService _retaggingService = RetaggingService();
  // final ClaimService _claimService = ClaimService();
  final CancelLeadService _cancelLeadService = CancelLeadService();
  final LeadRepository _leadRepository = LeadRepository();
  final DraftRepository _draftRepository = DraftRepository();
  
  String localLeadUuid = const Uuid().v4();
  bool draftCreated = false;

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

  void setInitialData(Map<String, dynamic> args) async {
    if (data != null) return;

    manualtagging = args["manualtagging"] ?? false;

    if (args.containsKey("leadUuid")) {
      final leadUuid = args["leadUuid"];
      localLeadUuid = leadUuid;
      final loadedData = await _leadRepository.loadDraftLead(leadUuid);
      if (loadedData != null && loadedData['lead'] != null) {
        final LeadModel draftLead = loadedData['lead'];
        data = {
          "id": draftLead.serverId,
          "local_uuid": draftLead.localUuid,
          "ownerName": draftLead.ownerName,
          "mobileNo": draftLead.mobileNumber,
          "village": draftLead.village,
        };
        draftCreated = true;
        initFieldsFromData(data as Map<String, dynamic>, Get.context!);
        update();
        return;
      }
    }

    if (manualtagging == true) {
      data = {
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
      };
    } else {
      data = args["tagging"] ?? args["retagging"] ?? args["claim"];
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
    buffalocountcontroller.text = _formatNumber(dataMap["numberOfBuffalo"]);
    cowcountcontroller.text = _formatNumber(dataMap["numberOfCow"]);
    buffalomoneycontroller.text = _formatNumber(dataMap["sumInsuredBuffalo"]);
    cowmoneycontroller.text = _formatNumber(dataMap["sumInsuredCow"]);
    species = dataMap["species"];
    tagnumberclaim = dataMap["tagNumber"] ?? dataMap["oldTagNumber"];
    dateofdeathcontroller.text = dataMap["dateOfDeath"] != null && dataMap["dateOfDeath"].toString().isNotEmpty
        ? dataMap["dateOfDeath"].toString()
        : '';
    timeofdeathcontroller.text = dataMap["timeOfDeath"] != null && dataMap["timeOfDeath"].toString().isNotEmpty
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
      // print("controllerimage::::$isimage");
    }
    // update();
    update(['cancelDialog']);
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

    // =============== DRAFT PERSISTENCE ===============
    try {
      final leadModel = LeadModel(
        localUuid: localLeadUuid,
        serverId: id,
        ownerName: namecontroller.text.trim(),
        mobileNumber: mobilenumbercontroller.text.trim(),
        village: villegcontroller.text.trim(),
        totalCattleCount: (int.tryParse(buffalocountcontroller.text.trim()) ?? 0) + (int.tryParse(cowcountcontroller.text.trim()) ?? 0),
        syncStatus: 'DRAFT',
      );

      if (!draftCreated && namecontroller.text.trim().isNotEmpty && mobilenumbercontroller.text.trim().isNotEmpty) {
        await _leadRepository.saveDraftLead(leadModel, []);
        draftCreated = true;
      } else if (draftCreated) {
        await _leadRepository.updateDraftLead(leadModel);
      }

      // Save draft progress
      await _draftRepository.saveDraftProgress(
        entityUuid: localLeadUuid,
        workflowType: retagging != null ? 'Retagging' : (ischangepage != null ? 'Claim' : 'Tagging'),
        currentStep: 1, // Step 1: Farmer/Lead Details
        lastScreenRoute: routetaggingdatapage,
        completionPercentage: 20.0,
      );

      // Inject localUuid so Cattle screen can pick it up
      if (data is Map<String, dynamic>) {
        (data as Map<String, dynamic>)['local_uuid'] = localLeadUuid;
      }
    } catch (e) {
      debugPrint("Failed to persist draft lead: $e");
    }
    // =================================================

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

      final response = await _cancelLeadService.cancelLead(
        token: token,
        leadId: id,
        leadType: leadType,
        reason: selectedReasonDropdown!,
        otherReason: selectedReasonDropdown == "Other" ? "Custom Reason" : null,
        images: images,
      );

      // ✅ CLOSE LOADER SAFELY
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      final responseBody = await response.stream.bytesToString();

      print("========= CANCEL RESPONSE =========");
      print(response.statusCode);
      print(responseBody);

      final decoded = jsonDecode(responseBody);

      // ✅ SUCCESS
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded["status"] == "success") {
        Get.offAllNamed(
          routehomepage,
          arguments: {"success": "Lead cancelled successfully"},
        );
      } else {
        // ❌ NO SNACKBAR HERE
        debugPrint(decoded["message"] ?? "Cancel failed");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print("CANCEL ERROR => $e");

      // ❌ NO SNACKBAR HERE
      debugPrint("Something went wrong");
    }
  }

  @override
  void onClose() {
    dateOfDeathFocusNode.dispose();
    timeOfDeathFocusNode.dispose();
    super.onClose();
  }
}
