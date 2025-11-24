import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/controller.dart';

class TaggingController extends GetxController {
  AppController appController = Get.find();
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController loanaccoutnumbercontroller = TextEditingController();
  TextEditingController nameofcattleownercontroller = TextEditingController();
  TextEditingController villagecontroller = TextEditingController();
  TextEditingController talukacontroller = TextEditingController();
  TextEditingController distcontroller = TextEditingController();

  bool listshow = true;
  bool manualtagging = false;

  // List<String> textList = [
  //   "Patel Apurv Anantbhai",
  //   "Patel Harsh Vikrambhai",
  //   "Patel Apurv Anantbhai",
  //   "Patel Harsh Vikrambhai",
  //   "Patel Apurv Anantbhai",
  //   "Patel Harsh Vikrambhai",
  //   "Patel Apurv Anantbhai",
  //   "Patel Harsh Vikrambhai",
  // ];

  List<Map<String, String>> textList = [
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "Insurance": "TATA AIG",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "Insurance": "New India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "Insurance": "TATA AIG",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "Insurance": "New India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "Insurance": "TATA AIG",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "Insurance": "New India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "Insurance": "TATA AIG",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "Insurance": "New India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "Insurance": "TATA AIG",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "Insurance": "New India",
    },
    {
      "name": "Patel Apurv Anantbhai",
      "mobile": "7572855882",
      "village": "Gabat",
      "taluko": "Bayad",
      "Insurance": "TATA AIG",
    },
    {
      "name": "Patel Harsh Vikrambhai",
      "mobile": "9876543210",
      "village": "Hathipura",
      "taluko": "Bayad",
      "Insurance": "New India",
    },
  ];

  // tagging page search

  void search() {
    // if (mobilecontroller.text.isNotEmpty ||
    //     loanaccoutnumbercontroller.text.isNotEmpty ||
    //     nameofcattleownercontroller.text.isNotEmpty ||
    //     villagecontroller.text.isNotEmpty ||
    //     talukacontroller.text.isNotEmpty ||
    //     distcontroller.text.isNotEmpty) {
    //   listshow = false;
    //   update();
    //   print("$listshow");
    // }
    Get.dialog(
      Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 60,
        ),
      ),
      barrierDismissible: false,
    );
    Future.delayed(Duration(seconds: 5), () {
      Get.back(); // close loading dialog
    });
    listshow = false;
    update();
  }
}
