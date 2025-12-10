import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/routes/common/common_app_pages.dart';

class CattleController extends GetxController {
  bool? cowreadOnly = false;
  bool? buffaloreadOnly = false;
  bool? taggingdate = false;
  dynamic data;
  String? ischangepage = "ischangepage";
  String? claimcattle = "claimcattle13";
  String? retagging = "retagging";
  TextEditingController buffalocountcontroller = TextEditingController();
  TextEditingController milklittercontroller = TextEditingController();
  TextEditingController buffalomoneycontroller = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void onInit() {
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
    if (selectedeartag.value != null ||
        selectedheadpose.value != null ||
        selectedsideposeleft.value != null ||
        selectedsideposeright.value != null ||
        selectedbackpose.value != null) {
      Get.dialog(
        Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 60,
          ),
        ),
        barrierDismissible: false,
      );

      // Delay for 5 seconds

      Future.delayed(Duration(seconds: 5), () {
        Get.toNamed(routefarmerdetailspage);
      });

      update();
    }
    update();
  }

  void saveclaim() {
    if (selectedeartag.value != null ||
        selectedheadpose.value != null ||
        selectedsideposeleft.value != null ||
        selectedsideposeright.value != null ||
        selectedbackpose.value != null ||
        selectedearcut.value != null ||
        selectedearbackside.value != null) {
      Get.dialog(
        Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 60,
          ),
        ),
        barrierDismissible: false,
      );

      // Delay for 5 seconds

      Future.delayed(Duration(seconds: 5), () {
        Get.toNamed(routefarmerdetailspage);
      });

      update();
    }
    update();
  }
}
