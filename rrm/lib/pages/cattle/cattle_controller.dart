import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/services/cattle_service.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';

class CattleController extends GetxController {
  final CattleService _cattleService = CattleService();

  bool? cowreadOnly = false;
  bool? buffaloreadOnly = false;
  bool? taggingdate = false;
  dynamic data;
  String? ischangepage;
  String? claimcattle;
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
  bool _isTagFieldsInitialized = false;

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
    totalCattleCount = _parseInt(args["totalCattleCount"]) ??
        _calculateTotalCattleCount(data);
    if (totalCattleCount < 1) totalCattleCount = 1;
    currentCattleIndex =
        _parseInt(args["cattleIndex"]) ?? (completedCattleCount + 1);
    _initializeTagFields();
  }

  void _initializeTagFields() {
    if (_isTagFieldsInitialized || data is! Map<String, dynamic>) return;
    final lead = data as Map<String, dynamic>;

    if (ischangepage == null && retagging == null) {
      // Tagging flow: user enters new tag number for each cattle.
      tagnumbercontroller.clear();
      newtagnumbercontroller.clear();
    } else {
      // Retagging/claim flow: prefill from lead.
      tagnumbercontroller.text =
          (lead["tagNumber"] ?? lead["oldTagNumber"] ?? "").toString();
      newtagnumbercontroller.text = (lead["newTagNumber"] ?? "").toString();
    }
    _isTagFieldsInitialized = true;
  }

  // cattle page
  final List<String> speciesnotavailable = [
    'Not Purchased',
    'Unhealthy Cattle',
    'Unproductive Cattle',
    'Under Value Cattle',
  ];

  final List<String> speciesItems = ['Buffalo',              'Cow', 'Sheep', 'Goat'];
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
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      isimage == 1
          ? selectedeartag.value = File(pickedFile.path)
          : isimage == 2
          ? selectedheadpose.value = File(pickedFile.path)
          : isimage == 3
          ? selectedsideposeleft.value = File(pickedFile.path)
          : isimage == 4
          ? selectedsideposeright.value = File(pickedFile.path)
          : isimage == 5
          ? selectedbackpose.value = File(pickedFile.path)
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
          : isimage == 11
          ? selectedearcut.value = File(pickedFile.path)
          : isimage == 12
          ? selectedearbackside.value = File(pickedFile.path)
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
      isimage == 1
          ? selectedeartag.value = File(result.files.single.path!)
          : isimage == 2
          ? selectedheadpose.value = File(result.files.single.path!)
          : isimage == 3
          ? selectedsideposeleft.value = File(result.files.single.path!)
          : isimage == 4
          ? selectedsideposeright.value = File(result.files.single.path!)
          : isimage == 5
          ? selectedbackpose.value = File(result.files.single.path!)
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
          : isimage == 11
          ? selectedearcut.value = File(result.files.single.path!)
          : isimage == 12
          ? selectedearbackside.value = File(result.files.single.path!)
          : null;
      // print("controllerimage::::$isimage");
    }
    update();
  }

  // camera video picker
  int? isvideo = 0;

  String? cameravideopath1;
  String? cameravideopath2;

  void pickVideoFromCamera() async {
    final pickedVideo = await _picker.pickVideo(source: ImageSource.camera);

    if (pickedVideo != null) {
      isvideo == 1
          ? cameravideopath1 = pickedVideo.path
          : isvideo == 2
          ? cameravideopath2 = pickedVideo.path
          : null;
    }

    // print("Selected video for isimage $isimage: ${pickedVideo?.path}");

    update();
  }

  // Gallery video picker
  String? videopath1;
  String? videopath2;

  void pickVideoFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      isvideo == 1
          ? videopath1 = result.files.single.path!
          : isvideo == 2
          ? videopath2 = result.files.single.path!
          : null;
    }

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
      galleryFiles.value = result.paths.map((path) => File(path!)).toList();
      // print("Picked files: ${galleryFiles.value.map((f) => f.path)}");
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

    final hasMandatoryImages = selectedeartag.value != null &&
        selectedheadpose.value != null &&
        selectedsideposeleft.value != null &&
        selectedsideposeright.value != null &&
        selectedbackpose.value != null;
    if (!hasMandatoryImages) {
      showSnackBar(
        "Please add all 5 mandatory cattle photos (ear tag, head, left, right, back).",
        SNACK.FAILED,
      );
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

    final payload = <String, dynamic>{
      "leadId": taggingId.toString(),
      "leadType": isClaimFlow ? "claim" : (retagging != null ? "retagging" : "tagging"),
      "cattleIndex": completedCattleCount,
      "totalCattle": totalCattleCount,
      "tagNumber": tagnumbercontroller.text.trim().isNotEmpty
          ? tagnumbercontroller.text.trim()
          : null,
      "taggingDate": taggingdatecontroller.text.trim().isNotEmpty
          ? taggingdatecontroller.text.trim()
          : null,
      "species": selectedSpeciesValue,
      "breed": selectedbreedValue,
      "bodyColor": selectedbodycolorValue,
      "rightHorn": selectedrighthornValue,
      "leftHorn": selectedlefthornValue,
      "tailColor": selectedtailcolorValue,
      "cattleAge": selectedAgeValue,
      "idMark": selectedidmarkValue,
      "milkPerDayLtr": _toNullableNumericString(milklittercontroller.text),
      "lactation": _toNullableNumericString(buffalocountcontroller.text),
      "sumInsured": _toNullableNumericString(buffalocountcontroller.text),
      "marketValue": _toNullableNumericString(buffalomoneycontroller.text),
      "earTagImage": selectedeartag.value != null
          ? base64Encode(selectedeartag.value!.readAsBytesSync())
          : null,
      "headPoseImage": selectedheadpose.value != null
          ? base64Encode(selectedheadpose.value!.readAsBytesSync())
          : null,
      "sidePoseLeftImage": selectedsideposeleft.value != null
          ? base64Encode(selectedsideposeleft.value!.readAsBytesSync())
          : null,
      "sidePoseRightImage": selectedsideposeright.value != null
          ? base64Encode(selectedsideposeright.value!.readAsBytesSync())
          : null,
      "backPoseImage": selectedbackpose.value != null
          ? base64Encode(selectedbackpose.value!.readAsBytesSync())
          : null,
      "earCutPhoto": selectedearcut.value != null
          ? base64Encode(selectedearcut.value!.readAsBytesSync())
          : null,
      "earBackSidePhoto": selectedearbackside.value != null
          ? base64Encode(selectedearbackside.value!.readAsBytesSync())
          : null,
    }..removeWhere((_, value) => value == null || (value is String && value.isEmpty));

    try {
      final resp = await _cattleService.submitCattle(
        token: token,
        payload: payload,
      );

      final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};

      if (resp.statusCode >= 200 && resp.statusCode < 300 && decoded['status'] == 'success') {
        showSnackBar("Cattle saved successfully.", SNACK.SUCCESS);
        final bool isTaggingFlow = ischangepage == null && retagging == null;

        if (isTaggingFlow) {
          final nextCompleted = completedCattleCount + 1;
          completedCattleCount = nextCompleted;
          if (nextCompleted < totalCattleCount) {
            // Keep user on same screen and move to next cattle step.
            currentCattleIndex = nextCompleted + 1;
            _resetCattleCaptureFormForNextStep();
            update();
          } else {
            showSnackBar("All cattle tagged for this lead.", SNACK.SUCCESS);
            Get.offAllNamed(routetaggingpage);
          }
        } else {
          // Claims/retagging continue to farmer details summary
          Get.offNamed(
            routefarmerdetailspage,
            arguments: {
              "tagging": data,
              "ischangepage": ischangepage,
              "retagging": retagging,
            },
          );
        }
      } else {
        showSnackBar(decoded['message'] ?? 'Failed to save cattle.', SNACK.FAILED);
      }
    } catch (e) {
      showSnackBar("Unable to save cattle: ${e.toString()}", SNACK.FAILED);
    } finally {
      isSubmitting = false;
      if (Get.isDialogOpen ?? false) Get.back();
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
    final total = totalFromLead > 0 ? totalFromLead : (buffalo + cow + sheep + goat);
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
    cameravideopath1 = null;
    cameravideopath2 = null;
    videopath1 = null;
    videopath2 = null;
    galleryFiles.clear();
  }
}
