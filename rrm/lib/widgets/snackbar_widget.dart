import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/utils/responsive.dart';


class SnackbarHelper {
  void showSnackBar(
    String message,
    SNACK type, {
    String? title,
    Duration? duration,
  }) {
    if (Get.context == null) return;

    Get.showSnackbar(
      GetSnackBar(
        titleText: title != null
            ? Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : const SizedBox.shrink(),
        messageText: Text(
          message,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: type == SNACK.SUCCESS ? Colors.green : Colors.red,
        snackStyle: SnackStyle.FLOATING,
        borderRadius: 10,
        padding: EdgeInsets.only(
          left: wp(5),
          right: wp(5),
          bottom: hp(3),
          top: hp(2),
        ),
        margin: EdgeInsets.symmetric(horizontal: wp(5), vertical: hp(5)),
        forwardAnimationCurve: Curves.easeOut,
        reverseAnimationCurve: Curves.easeIn,
      ),
    );
  }
}

void showSnackBar(String message, SNACK type) {
  final context = Get.context;

  if (context == null) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          type == SNACK.SUCCESS ? Colors.green : Colors.red,
      duration: const Duration(seconds: 2),
    ),
  );
}

