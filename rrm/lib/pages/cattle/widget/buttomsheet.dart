import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customcontainer.dart';

buttomsheet({
  required BuildContext context,
  required controller,
  int? isimage,
  int? isvideo,
}) {
  return showModalBottomSheet<void>(
    backgroundColor: AppColors.PRIMARY_COLOR,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(top: hp(2)),
        child: SizedBox(
          height: hp(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Customcontainer(
                onTap: () {
                  controller.isvideo != null
                      ? controller.pickVideoFromCamera()
                      : controller.pickFromCamera();
                  controller.isvideo != null
                      ? controller.isvideo = isvideo
                      : controller.isimage = isimage;
                  Get.back();
                },
                context: context,
                text: "Camera",
                icon: Icons.camera,
              ),
              SizedBox(width: wp(5)),
              Customcontainer(
                onTap: () {
                  controller.isvideo != null
                      ? controller.pickVideoFromGallery()
                      : controller.picFromGallery();
                  controller.isvideo != null
                      ? controller.isvideo = isvideo
                      : controller.isimage = isimage;
                  Get.back();
                },
                context: context,
                text: "Gallery",
                icon: Icons.image,
              ),
            ],
          ),
        ),
      );
    },
  );
}
