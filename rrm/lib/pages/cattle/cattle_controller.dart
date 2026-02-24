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

  @override
  void onInit() {
    // Capture navigation arguments once to avoid nulls on rebuilds
    final Map<String, dynamic> args = (Get.arguments as Map<String, dynamic>?) ?? {};
    data = args["tagging"];
    ischangepage = args["ischangepage"];
    retagging = args["retagging"];

    completedCattleCount = _parseInt(args["completedCattleCount"]) ?? 0;
    totalCattleCount = _parseInt(args["totalCattleCount"]) ?? _calculateTotalCattleCount(data);
    if (totalCattleCount < 1) totalCattleCount = 1;
    currentCattleIndex = _parseInt(args["cattleIndex"]) ?? (completedCattleCount + 1);

    selectedSpeciesValue ??= speciesItems.first; // Set default to first item
    super.onInit();
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

    if (selectedeartag.value == null &&
        selectedheadpose.value == null &&
        selectedsideposeleft.value == null &&
        selectedsideposeright.value == null &&
        selectedbackpose.value == null &&
        (!isClaimFlow || (selectedearcut.value == null && selectedearbackside.value == null))) {
      showSnackBar("Please add at least one cattle photo.", SNACK.FAILED);
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
      "taggingId": taggingId,
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
      "switchOfTail": selectedtailcolorValue,
      "cattleAge": selectedAgeValue,
      "idMark": selectedidmarkValue,
      "milkPerDayLtr": _toNullableDouble(milklittercontroller.text),
      "lactation": _toNullableDouble(buffalocountcontroller.text),
      "sumInsured": _toNullableDouble(buffalomoneycontroller.text),
      "marketValue": _toNullableDouble(buffalomoneycontroller.text),
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
          if (nextCompleted < totalCattleCount) {
            // Go back to cattle capture for next animal in tagging flow
            Get.offNamed(
              routecattlepage,
              arguments: {
                "tagging": data,
                "ischangepage": ischangepage,
                "retagging": retagging,
                "completedCattleCount": nextCompleted,
                "totalCattleCount": totalCattleCount,
                "cattleIndex": nextCompleted + 1,
              },
            );
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

  double? _toNullableDouble(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
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
}
