import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';

class HomeController extends GetxController {
  String? retagging = "retagging";
  AppController appController = Get.find();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
}
