// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

double wp(double percentage) {
  double result = (Get.width * percentage) / 100;

  return result;
}

double hp(double percentage) {
  double result = (Get.height * percentage) / 100;
  return result;
}

double dp(BuildContext context, double size) {
  return size * MediaQuery.textScaleFactorOf(context);
}
