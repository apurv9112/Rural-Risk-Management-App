import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/dependency_injection.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/utils/responsive.dart';

class SnackbarHelper {
  void showSnackBar(
    String message,
    SNACK type, {
    String? title,
    Duration? duration,
  }) {
    if (Get.context != null) {
      Get.snackbar(
        title ?? '',
        '',
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: type == SNACK.SUCCESS ? Colors.green : Colors.red,
        snackStyle: SnackStyle.FLOATING,
        borderRadius: 10,
        colorText: Colors.white,
        titleText: Container(height: 0),
        padding: EdgeInsets.only(
          left: wp(5),
          right: wp(5),
          bottom: hp(3),
          top: hp(2),
        ),
        messageText: Text(
          message,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ), // Adjust your style accordingly
        ),
        margin: EdgeInsets.symmetric(horizontal: wp(5), vertical: hp(5)),
      );
    }
  }
}

void showSnackBar(
  String message,
  SNACK type, {
  String? title,
  Duration? duration,
}) {
  getIt<SnackbarHelper>().showSnackBar(
    message,
    type,
    duration: duration,
    title: title,
  );
}
