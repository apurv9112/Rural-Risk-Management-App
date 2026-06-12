
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/core/storage/folder_manager.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/services/cattle_service.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';
import 'package:rrm/services/location_service.dart';
import 'package:rrm/services/image_processing_service.dart';

import 'package:rrm/dependency_injection.dart';
import 'package:rrm/services/offline/queue_insertion_service.dart';
import 'package:rrm/services/image_watermark_service.dart';
import 'package:rrm/services/camera_service.dart';

class CattleController extends GetxController {


  bool? cowreadOnly = false;
  bool? buffaloreadOnly = false;
  bool? taggingdate = false;
  dynamic data;
  String? ischangepage;
  String? claimcattle;
  TextEditingController sumInsuredController = TextEditingController();
  TextEditingController marketValueController = TextEditingController();
  String? retagging;
  TextEditingController buffalocountcontroller = TextEditingController();
  TextEditingController milklittercontroller = TextEditingController();
  TextEditingController buffalomoneycontroller = TextEditingController();
  final AppController appController = Get.find();
  bool isSubmitting = false;
  GlobalKey<FormState> formKey = GlobalKey();
  int totalCattleCount = 1;
  int completedCattleCount = 0;
  int currentCattleIndex = 1;

  List<Map<String, dynamic>> cattleSequence = [];

  @override
  void onInit() {
    final Map<String, dynamic> args =
        (Get.arguments as Map<String, dynamic>?) ?? {};
    syncFromArgs(args);
    selectedSpeciesValue ??= speciesItems.first; // Set default to first item
    super.onInit();
  }

  void syncFromArgs(Map<String, dynamic> args) {
    data = args["tagging"] ?? data;
    ischangepage = args["ischangepage"] ?? ischangepage;
    retagging = args["retagging"] ?? retagging;

    completedCattleCount =
        _parseInt(args["completedCattleCount"]) ?? completedCattleCount;
    totalCattleCount =
        _parseInt(args["totalCattleCount"]) ?? _calculateTotalCattleCount(data);
    if (totalCattleCount < 1) totalCattleCount = 1;
    currentCattleIndex =
        _parseInt(args["cattleIndex"]) ?? (completedCattleCount + 1);
    _initializeTagFields();
    currentCattleIndex =
        _parseInt(args["cattleIndex"]) ?? (completedCattleCount + 1);

    _prepareCattleSequence();

    _initializeTagFields();
  }

  String formatAmount(dynamic value) {
    if (value == null) return "";

    final number = num.tryParse(value.toString());

    if (number == null) return "";

    return number.toInt().toString();
  }

  void updateSumInsuredBySpecies(String species) {
    if (data is! Map<String, dynamic>) return;

    final lead = data as Map<String, dynamic>;

    if (species == "Buffalo") {
      sumInsuredController.text = formatAmount(lead["sumInsuredBuffalo"]);
    } else if (species == "Cow") {
      sumInsuredController.text = formatAmount(lead["sumInsuredCow"]);
    } else {
      sumInsuredController.clear();
    }

    update();
  }

  void _prepareCattleSequence() {
    cattleSequence.clear();

    if (data is! Map<String, dynamic>) return;

    final lead = data as Map<String, dynamic>;

    final buffaloCount = _parseInt(lead["numberOfBuffalo"]) ?? 0;
    final cowCount = _parseInt(lead["numberOfCow"]) ?? 0;

    final buffaloSI = formatAmount(lead["sumInsuredBuffalo"]);

    final cowSI = formatAmount(lead["sumInsuredCow"]);

    // Buffalo sequence
    for (int i = 0; i < buffaloCount; i++) {
      cattleSequence.add({"species": "Buffalo", "sumInsured": buffaloSI});
    }

    // Cow sequence
    for (int i = 0; i < cowCount; i++) {
      cattleSequence.add({"species": "Cow", "sumInsured": cowSI});
    }

    // Initial auto set
    if (cattleSequence.isNotEmpty &&
        completedCattleCount < cattleSequence.length) {
      final current = cattleSequence[completedCattleCount];

      selectedSpeciesValue = current["species"];

      sumInsuredController.text = current["sumInsured"] ?? "";
    }
  }

  void _initializeTagFields() {
    if (data is! Map<String, dynamic>) return;
    final lead = data as Map<String, dynamic>;

    if (ischangepage == null && retagging == null) {
      // Tagging flow: user enters new tag number for each cattle.
      tagnumbercontroller.clear();
      newtagnumbercontroller.clear();
      taggingdatecontroller.text = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());
    } else {
      // Retagging/claim flow: prefill from lead.
      tagnumbercontroller.text =
          (lead["tagNumber"] ?? lead["oldTagNumber"] ?? "").toString();

      if (retagging != null) {
        taggingdatecontroller.text =
            (lead["taggingDate"] ?? lead["oldTagDate"] ?? "").toString();
        newtagnumbercontroller.text = (lead["newTagNumber"] ?? "").toString();
        newtaggingdatecontroller.text = (lead["dateOfReTagging"] ?? "")
            .toString();
      } else {
        newtagnumbercontroller.text = (lead["newTagNumber"] ?? "").toString();
      }
    }
  }

  // cattle page
  final List<String> speciesnotavailable = [
    'Not Purchased',
    'Unhealthy Cattle',
    'Unproductive Cattle',
    'Under Value Cattle',
  ];

  final List<String> speciesItems = ['Buffalo', 'Cow', 'Sheep', 'Goat'];
  final List<String> ageBuffaloCow = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];
  final List<String> ageSheepGoat = [
    '1',
    '1.5',
    '2',
    '2.5',
    '3',
    '3.5',
    '4',
    '5',
    '6',
    '7',
  ];
  final List<String> breedItemsBuffalo = [
    'Mehsani',
    'Surati',
    'Jafrabadi',
    'Murrah',
    'Banni',
  ];
  final List<String> breedItemsCow = [
    'HF.Cross',
    'Jr.Cross',
    'Kankrej',
    'Gir',
    'Rathi',
    'Nagori',
    'Shahiwal',
  ];
  final List<String> breedItemsSheep = [
    'Marwari',
    'Magra',
    'Chokla',
    'Nali',
    'Pugal',
    'Jaisalmeri',
    'Malpura',
    'Sonadi',
    'Patanwadi',
  ];
  final List<String> breedItemsGoat = [
    'Kutchi',
    'Surti',
    'Zalawadi',
    'Mehsana',
    'Gohilwadi',
    'Kahmi',
    'Sirohi',
    'Marwari',
    'Jakhrana',
    'Sojat',
    'Karauli',
    'Gujari',
    "Jamunapari",
    "Barbari",
  ];
  final List<String> bodycolorItemsBuffalo = ['Black', 'G.Black', 'Grey'];
  final List<String> bodycolorItemsCow = [
    'Black',
    'Brown',
    'Br&Bl',
    'Bl&Wt',
    'O.White',
    'Br&Wt',
    'WHITE',
  ];
  final List<String> bodycolorItemsSheep = [
    'Black',
    'Brown',
    'Br&Bl',
    'Bl&Wt',
    'O.White',
    'Br&Wt',
    'Tan',
    'WHITE',
  ];
  final List<String> bodycolorItemsGoat = [
    'Black',
    'Brown',
    'Br&Bl',
    'Bl&Wt',
    'O.White',
    'Br&Wt',
    'Tan',
    'WHITE',
  ];
  final List<String> righthornItemsBuffalo = [
    'Sideward',
    'Downward',
    'Rolled',
    'Curved',
    'Broken',
    'Sickle',
  ];
  final List<String> righthornItemsCow = [
    'Dehorned',
    'Forward',
    'Short',
    'Crescent',
    'Downward',
  ];
  final List<String> righthornItemsSheep = [
    'Polled',
    'Curved',
    'Twisted',
    'Spiral',
    'Button',
  ];
  final List<String> righthornItemsGoat = [
    'Polled',
    'Curved',
    'Upward',
    'Spiral',
    'Sideward',
    'Scurs',
  ];
  final List<String> lefthornItemsBuffalo = [
    'Sideward',
    'Downward',
    'Rolled',
    'Curved',
    'Broken',
    'Sickle',
  ];
  final List<String> lefthornItemsCow = [
    'Dehorned',
    'Forward',
    'Short',
    'Crescent',
    'Downward',
  ];
  final List<String> lefthornItemsSheep = [
    'Polled',
    'Curved',
    'Twisted',
    'Spiral',
    'Button',
  ];
  final List<String> lefthornItemsGoat = [
    'Polled',
    'Curved',
    'Upward',
    'Spiral',
    'Sideward',
    'Scurs',
  ];
  final List<String> tailcolorItems = ['Black', 'Gray', 'White', 'brown'];
  final List<String> idmarkItems = ['Star', 'Nil'];
  final List<String> milkdayItems = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
  ];
  final List<String> lactationItems = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
  ];
  String? selectedspeciesnotavailable;
  String? selectedSpeciesValue;
  String? selectedAgeValue;
  String? selectedbreedValue;
  String? selectedbodycolorValue;
  String? selectedrighthornValue;
  String? selectedlefthornValue;
  String? selectedtailcolorValue;
  String? selectedidmarkValue;
  String? selectedmilkdayValue;
  String? selectedlactationValue;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  Rx<DateTime?> selectedDatenew = Rx<DateTime?>(DateTime.now());

  TextEditingController tagnumbercontroller = TextEditingController();
  TextEditingController newtagnumbercontroller = TextEditingController();
  TextEditingController taggingdatecontroller = TextEditingController();
  TextEditingController newtaggingdatecontroller = TextEditingController();

  bool get isSuccessfullyTagging {
    return selectedspeciesnotavailable == null ||
        selectedspeciesnotavailable == 'Successfully Tagging';
  }

  final FocusNode tagNumberFocusNode = FocusNode();
  final FocusNode newTagNumberFocusNode = FocusNode();
  final FocusNode breedFocusNode = FocusNode();
  final FocusNode rightHornFocusNode = FocusNode();
  final FocusNode tailColorFocusNode = FocusNode();
  final FocusNode milkLitterFocusNode = FocusNode();
  final FocusNode ageFocusNode = FocusNode();
  final FocusNode bodyColorFocusNode = FocusNode();
  final FocusNode leftHornFocusNode = FocusNode();
  final FocusNode idMarkFocusNode = FocusNode();
  final FocusNode lactationFocusNode = FocusNode();
  final FocusNode marketValueFocusNode = FocusNode();

  // date picker

  void pickDate(BuildContext context, {required controller}) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? today,
      firstDate: today, // 🔒 Prevent past dates
      lastDate: DateTime(2100),

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green, // ✅ header background + selected date
              onPrimary: Colors.white, // ✅ selected date text
              onSurface: Colors.black, // ✅ calendar text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // ✅ OK/Cancel button text
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      taggingdate == true
          ? selectedDate.value = picked
          : selectedDatenew.value = picked;
      update();
      // print("fdfdf :::: ${controller.selectedDate.value}");
    }
  }

  // image picker

  int? isimage = 0;
  Rx<File?> selectedeartag = Rx<File?>(null);
  Rx<File?> selectedheadpose = Rx<File?>(null);
  Rx<File?> selectedsideposeleft = Rx<File?>(null);
  Rx<File?> selectedsideposeright = Rx<File?>(null);
  Rx<File?> selectedbackpose = Rx<File?>(null);
  Rx<File?> selectedOther5 = Rx<File?>(null);
  Rx<File?> selectedOther1 = Rx<File?>(null);
  Rx<File?> selectedOther2 = Rx<File?>(null);
  Rx<File?> selectedOther3 = Rx<File?>(null);
  Rx<File?> selectedOther4 = Rx<File?>(null);
  Rx<File?> selectedearcut = Rx<File?>(null);
  Rx<File?> selectedearbackside = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  //image  picker
  void pickFromCamera() async {
    final position = await LocationService.getCurrentLocation();
    if (position == null) {
      return;
    }

    final pickedFile = await CameraService.captureImage();
    if (pickedFile != null) {
      File file = File(pickedFile.path);

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      try {
        file = await ImageProcessingService.processImage(file);
        file = await ImageWatermarkService.addWatermark(file, position);
      } catch (e) {
        print("Image processing error: $e");
      }
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      isimage == 1
          ? selectedeartag.value = file
          : isimage == 2
          ? selectedheadpose.value = file
          : isimage == 3
          ? selectedsideposeleft.value = file
          : isimage == 4
          ? selectedsideposeright.value = file
          : isimage == 5
          ? selectedbackpose.value = file
          : isimage == 6
          ? selectedOther5.value = file
          : isimage == 7
          ? selectedOther1.value = file
          : isimage == 8
          ? selectedOther2.value = file
          : isimage == 9
          ? selectedOther3.value = file
          : isimage == 10
          ? selectedOther4.value = file
          : isimage == 11
          ? selectedearcut.value = file
          : isimage == 12
          ? selectedearbackside.value = file
          : null;
      // print("controllerimage::::$isimage");
    }
    update();
  }

  void picFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false, // Only one for dropdown
    );
    if (result != null && result.files.single.path != null) {
      File file = await FolderManager.moveFromCache(File(result.files.single.path!), workflow: 'temp');

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
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

      isimage == 1
          ? selectedeartag.value = file
          : isimage == 2
          ? selectedheadpose.value = file
          : isimage == 3
          ? selectedsideposeleft.value = file
          : isimage == 4
          ? selectedsideposeright.value = file
          : isimage == 5
          ? selectedbackpose.value = file
          : isimage == 6
          ? selectedOther5.value = file
          : isimage == 7
          ? selectedOther1.value = file
          : isimage == 8
          ? selectedOther2.value = file
          : isimage == 9
          ? selectedOther3.value = file
          : isimage == 10
          ? selectedOther4.value = file
          : isimage == 11
          ? selectedearcut.value = file
          : isimage == 12
          ? selectedearbackside.value = file
          : null;
      // print("controllerimage::::$isimage");
    }
    update();
  }

  // // camera video picker
  // int? isvideo = 0;

  // String? cameravideopath1;
  // String? cameravideopath2;

  // void pickVideoFromCamera() async {
  //   final pickedVideo = await _picker.pickVideo(source: ImageSource.camera);

  //   if (pickedVideo != null) {
  //     isvideo == 1
  //         ? cameravideopath1 = pickedVideo.path
  //         : isvideo == 2
  //         ? cameravideopath2 = pickedVideo.path
  //         : null;
  //   }

  //   // print("Selected video for isimage $isimage: ${pickedVideo?.path}");

  //   update();
  // }

  // // Gallery video picker
  // String? videopath1;
  // String? videopath2;

  // void pickVideoFromGallery() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.video,
  //     allowMultiple: false,
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     isvideo == 1
  //         ? videopath1 = result.files.single.path!
  //         : isvideo == 2
  //         ? videopath2 = result.files.single.path!
  //         : null;
  //   }

  //   update();
  // }

  int? isvideo = 0;
  // Gallery video picker
  String? videopath1;
  String? videopath2;

  // String? cameravideopath1;
  // String? cameravideopath2;

  void pickVideoFromCamera() async {
    final pickedVideo = await _picker.pickVideo(source: ImageSource.camera);

    if (pickedVideo != null) {
      final persistentFile = await FolderManager.moveFromCache(File(pickedVideo.path), workflow: 'temp');
      isvideo == 1
          ? videopath1 = persistentFile.path
          : isvideo == 2
          ? videopath2 = persistentFile.path
          : null;
    }

    // print("Selected video for isimage $isimage: ${pickedVideo?.path}");
    print("CameraVideo 1 => $videopath1");
    print("CameraVideo 2 => $videopath2");
    update();
  }

  void pickVideoFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final persistentFile = await FolderManager.moveFromCache(File(result.files.single.path!), workflow: 'temp');
      isvideo == 1
          ? videopath1 = persistentFile.path
          : isvideo == 2
          ? videopath2 = persistentFile.path
          : null;
    }
    print("galleryVideo 1 => $videopath1");
    print("galleryVideo 2 => $videopath2");
    update();
  }

  // MultiplePhotosAndVideos

  RxList<File> galleryFiles = <File>[].obs;

  Future<void> pickMultiplePhotosAndVideos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'mp4',
        'mov',
        'mkv',
      ], // ✅ Add as needed
      allowMultiple: true,
    );

    if (result != null) {
      List<File> processedFiles = [];
      for (var path in result.paths) {
        if (path != null) {
          final persistentFile = await FolderManager.moveFromCache(File(path), workflow: 'temp');
          processedFiles.add(persistentFile);
        }
      }
      galleryFiles.value = processedFiles;
    }
    update();
  }

  void savecattle() {
    _submitCattle(isClaimFlow: false);
  }

  void saveclaim() {
    _submitCattle(isClaimFlow: true);
  }

  Future<void> _submitCattle({required bool isClaimFlow}) async {
    if (isSubmitting) return;

    if (isSuccessfullyTagging) {
      final isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        _focusFirstInvalidField();
        return;
      }
    }

    final token = appController.token.value;

    if (token.isEmpty) {
      showSnackBar("Session expired. Please log in again.", SNACK.FAILED);

      return;
    }

    final taggingId = data is Map<String, dynamic> ? data['id'] : null;

    if (taggingId == null) {
      showSnackBar("Tagging data not found.", SNACK.FAILED);

      return;
    }

    if (completedCattleCount >= totalCattleCount) {
      showSnackBar("All cattle already saved for this lead.", SNACK.FAILED);

      return;
    }

    if (isSuccessfullyTagging) {
      final hasMandatoryImages =
          selectedeartag.value != null &&
          selectedheadpose.value != null &&
          selectedsideposeleft.value != null &&
          selectedsideposeright.value != null &&
          selectedbackpose.value != null;

      if (!hasMandatoryImages) {
        showSnackBar("Please add all 5 mandatory cattle photos.", SNACK.FAILED);

        return;
      }
    }

    // ================= LEAD TYPE =================

    String leadType = "tagging";

    if (retagging == "retagging") {
      leadType = "retagging";
    } else if (isClaimFlow) {
      leadType = "claim";
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
      barrierColor: Colors.black45,
      barrierDismissible: false,
    );

    try {
      final payload = <String, dynamic>{
        // ================= BASIC =================
        "leadId": taggingId.toString(),

        "leadType": leadType,

        // ignore: dead_null_aware_expression
        "cattleIndex": completedCattleCount.toString() ?? "",

        // ignore: dead_null_aware_expression
        "totalCattle": totalCattleCount.toString() ?? "",

        "tagNumber": retagging == "retagging"
            ? newtagnumbercontroller.text.trim()
            : tagnumbercontroller.text.trim(),

        // ignore: dead_null_aware_expression
        "taggingDate": taggingdatecontroller.text.trim() ?? "",

        "species": selectedSpeciesValue?.toUpperCase() ?? "",

        "breed": selectedbreedValue?.toUpperCase() ?? "",

        "bodyColor": selectedbodycolorValue?.toUpperCase() ?? "",

        "rightHorn": selectedrighthornValue?.toUpperCase() ?? "",

        "leftHorn": selectedlefthornValue?.toUpperCase() ?? "",

        "tailColor": selectedtailcolorValue?.toUpperCase() ?? "",

        "cattleAge": selectedAgeValue ?? "",

        "idMark": selectedidmarkValue ?? "",

        "milkPerDayLtr":
            _toNullableNumericString(milklittercontroller.text) ?? "",

        "lactation": selectedlactationValue?.toUpperCase() ?? "",

        "sumInsured": _toNullableNumericString(sumInsuredController.text) ?? "",

        "marketValue":
            _toNullableNumericString(marketValueController.text) ?? "",

        // ================= MAIN IMAGES =================
        "earTagImage": selectedeartag.value ?? "",

        "headPoseImage": selectedheadpose.value ?? "",

        "sidePoseLeftImage": selectedsideposeleft.value ?? "",

        "sidePoseRightImage": selectedsideposeright.value ?? "",

        "backPoseImage": selectedbackpose.value ?? "",

        "earCutPhoto": selectedearcut.value ?? "",

        "earBackSidePhoto": selectedearbackside.value ?? "",

        // ================= RETAGGING =================
        "dateOfReTagging": leadType == "retagging"
            ? newtaggingdatecontroller.text.trim()
            : "",

        "oldTagNumber": leadType == "retagging"
            ? tagnumbercontroller.text.trim()
            : "",

        "oldTagDate": leadType == "retagging"
            ? taggingdatecontroller.text.trim()
            : "",

        "oldEarTagImage": "",
        "oldHeadPoseImage": "",
        "oldSidePoseLeftImage": "",
        "oldSidePoseRightImage": "",
        "oldBackPoseImage": "",

        // ================= TAGGING COPY =================
        "taggingEarTagImage": selectedeartag.value ?? "",

        "taggingHeadPoseImage": selectedheadpose.value ?? "",

        "taggingSidePoseLeftImage": selectedsideposeleft.value ?? "",

        "taggingSidePoseRightImage": selectedsideposeright.value ?? "",

        "taggingBackPoseImage": selectedbackpose.value ?? "",

        // ================= CLAIM =================
        "dateOfDeath": leadType == "claim"
            ? selectedDate.value?.toString().split(" ")[0] ?? ""
            : "",

        "timeOfDeath": leadType == "claim"
            ? TimeOfDay.now().format(Get.context!)
            : "",

        "causeOfDeath": leadType == "claim" ? "ILLNESS" : "",

        // ================= VIDEOS =================
        "reTaggingVideo": videopath1 != null ? File(videopath1!) : "",

        "fullCattleVideo": videopath2 != null ? File(videopath2!) : "",

        // ================= PDF =================
        "conversionPdf": "",
      };

      print("========== PAYLOAD ==========");

      payload.forEach((key, value) {
        if (value is File) {
          print("$key => FILE: ${value.path}");
        } else {
          print("$key => $value");
        }
      });

      print("================================");

      final queueService = getIt<QueueInsertionService>();
      await queueService.enqueuePayload(
        payload,
        endpoint: "/field-worker/save-cattle",
      );

      // Simulate a small delay for smooth UI transition
      await Future.delayed(const Duration(milliseconds: 500));

      final nextCompleted = completedCattleCount + 1;

      completedCattleCount = nextCompleted;

      if (nextCompleted < totalCattleCount) {
        showSnackBar("Cattle saved. Next cattle...", SNACK.SUCCESS);

        currentCattleIndex = nextCompleted + 1;

        _resetCattleCaptureFormForNextStep();

        update();
      } else {
        showSnackBar("All cattle completed.", SNACK.SUCCESS);

        Get.offNamed(
          routesignaturepage,
          arguments: {
            "tagging": data,
            "ischangepage": ischangepage,
            "retagging": retagging,
          },
        );
      }
    } catch (e) {
      print("========== ERROR ==========");
      print(e.toString());
      print("===========================");

      showSnackBar("Unable to save cattle: ${e.toString()}", SNACK.FAILED);
    } finally {
      isSubmitting = false;

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      update();
    }
  }

  String? _toNullableNumericString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = num.tryParse(trimmed);
    return parsed?.toString();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  int _calculateTotalCattleCount(dynamic source) {
    if (source is! Map<String, dynamic>) return 1;
    final buffalo = _parseInt(source["numberOfBuffalo"]) ?? 0;
    final cow = _parseInt(source["numberOfCow"]) ?? 0;
    final sheep = _parseInt(source["numberOfSheep"]) ?? 0;
    final goat = _parseInt(source["numberOfGoat"]) ?? 0;
    final totalFromLead = _parseInt(source["totalCattle"]) ?? 0;
    final total = totalFromLead > 0
        ? totalFromLead
        : (buffalo + cow + sheep + goat);
    return total > 0 ? total : 1;
  }

  void _resetCattleCaptureFormForNextStep() {
    // Clear text inputs used for per-cattle capture.
    milklittercontroller.clear();
    buffalocountcontroller.clear();
    buffalomoneycontroller.clear();
    tagnumbercontroller.clear();
    newtagnumbercontroller.clear();

    // Keep tagging date to current date for convenience.
    selectedDate.value = DateTime.now();
    taggingdatecontroller.text = '';
    newtaggingdatecontroller.text = '';

    // Reset dropdown selections for next cattle.
    selectedspeciesnotavailable = null;
    selectedSpeciesValue = speciesItems.first;
    selectedAgeValue = null;
    selectedbreedValue = null;
    selectedbodycolorValue = null;
    selectedrighthornValue = null;
    selectedlefthornValue = null;
    selectedtailcolorValue = null;
    selectedidmarkValue = null;
    selectedmilkdayValue = null;
    selectedlactationValue = null;

    // Reset captured media.
    selectedeartag.value = null;
    selectedheadpose.value = null;
    selectedsideposeleft.value = null;
    selectedsideposeright.value = null;
    selectedbackpose.value = null;
    selectedOther5.value = null;
    selectedOther1.value = null;
    selectedOther2.value = null;
    selectedOther3.value = null;
    selectedOther4.value = null;
    selectedearcut.value = null;
    selectedearbackside.value = null;
    // cameravideopath1 = null;
    // cameravideopath2 = null;
    videopath1 = null;
    videopath2 = null;
    galleryFiles.clear();

    // Auto set next cattle species & SI
    if (cattleSequence.isNotEmpty &&
        completedCattleCount < cattleSequence.length) {
      final current = cattleSequence[completedCattleCount];

      selectedSpeciesValue = current["species"];

      sumInsuredController.text = current["sumInsured"] ?? "";
    }
  }

  void _focusFirstInvalidField() {
    if (tagnumbercontroller.text.trim().isEmpty) {
      tagNumberFocusNode.requestFocus();
      return;
    }
    if (retagging != null && newtagnumbercontroller.text.trim().isEmpty) {
      newTagNumberFocusNode.requestFocus();
      return;
    }
    if (selectedAgeValue == null || selectedAgeValue!.trim().isEmpty) {
      ageFocusNode.requestFocus();
      return;
    }
    if (selectedbreedValue == null || selectedbreedValue!.trim().isEmpty) {
      breedFocusNode.requestFocus();
      return;
    }
    if (selectedbodycolorValue == null ||
        selectedbodycolorValue!.trim().isEmpty) {
      bodyColorFocusNode.requestFocus();
      return;
    }
    if (selectedrighthornValue == null ||
        selectedrighthornValue!.trim().isEmpty) {
      rightHornFocusNode.requestFocus();
      return;
    }
    if (selectedlefthornValue == null ||
        selectedlefthornValue!.trim().isEmpty) {
      leftHornFocusNode.requestFocus();
      return;
    }
    if (selectedtailcolorValue == null ||
        selectedtailcolorValue!.trim().isEmpty) {
      tailColorFocusNode.requestFocus();
      return;
    }
    if (selectedidmarkValue == null || selectedidmarkValue!.trim().isEmpty) {
      idMarkFocusNode.requestFocus();
      return;
    }
    if (milklittercontroller.text.trim().isEmpty) {
      milkLitterFocusNode.requestFocus();
      return;
    }
    if (selectedlactationValue == null ||
        selectedlactationValue!.trim().isEmpty) {
      lactationFocusNode.requestFocus();
      return;
    }
    if (marketValueController.text.trim().isEmpty) {
      marketValueFocusNode.requestFocus();
      return;
    }
  }
}
