import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:rrm/pages/cattle/widget/buttomsheet.dart';
import 'package:rrm/widgets/custom_row.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';

iscattleimage({required BuildContext context, required controller}) {
  return Column(
    children: [
      customRow(
        videoicon: false,
        isvideoimag: false,
        context: context,
        controller: controller,
        textdata: "Ear Tag",
        childimage: controller.selectedeartag.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedeartag.value != null) {
                    showImagePreview(context, controller.selectedeartag.value!);
                  }
                },
                child: Image.file(
                  controller.selectedeartag.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),

        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870a.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870a.jpg"
            : "assets/Claim_Sample/100291577351a.jpeg",
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 1);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: false,
        context: context,
        controller: controller,
        textdata: "Head Pose",
        childimage: controller.selectedheadpose.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedheadpose.value != null) {
                    showImagePreview(
                      context,
                      controller.selectedheadpose.value!,
                    );
                  }
                },
                child: Image.file(
                  controller.selectedheadpose.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),
        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870b.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870b.jpg"
            : "assets/Claim_Sample/100291577351b.jpeg",
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 2);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: false,
        context: context,
        controller: controller,
        textdata: "Side Pose 1(Left)",
        childimage: controller.selectedsideposeleft.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedsideposeleft.value != null) {
                    showImagePreview(
                      context,
                      controller.selectedsideposeleft.value!,
                    );
                  }
                },
                child: Image.file(
                  controller.selectedsideposeleft.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),
        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870c.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870c.jpg"
            : "assets/Claim_Sample/100291577351c.jpeg",
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 3);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: false,
        context: context,
        controller: controller,
        textdata: "Back Pose",
        childimage: controller.selectedbackpose.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedbackpose.value != null) {
                    showImagePreview(
                      context,
                      controller.selectedbackpose.value!,
                    );
                  }
                },
                child: Image.file(
                  controller.selectedbackpose.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),
        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870e.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870e.jpg"
            : "assets/Claim_Sample/100291577351e.jpeg",
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 5);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: false,
        context: context,
        controller: controller,
        textdata: "Side Pose 2(Right)",
        childimage: controller.selectedsideposeright.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedsideposeright.value != null) {
                    showImagePreview(
                      context,
                      controller.selectedsideposeright.value!,
                    );
                  }
                },
                child: Image.file(
                  controller.selectedsideposeright.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),
        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870d.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870d.jpg"
            : "assets/Claim_Sample/100291577351d.jpeg",
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 4);
        },
      ),

      SizedBox(height: hp(1)),
      customRow(
        videoicon: true,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: controller.ischangepage == null
            ? "Tagging Video"
            : controller.retagging != null
            ? "Retagging Video"
            : "Ear Cutting Video",
        childimage: controller.videopath1 != null || controller.isvideo == 1
            ? Icon(
                Icons.video_library,
                color: AppColors.PRIMARY_COLOR,
                size: dp(context, 30),
              )
            : SizedBox(),
        onTap: () {
          buttomsheet(context: context, controller: controller, isvideo: 1);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: true,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Full Cattle Video",
        childimage: controller.videopath2 != null || controller.isvideo == 2
            ? Icon(
                Icons.video_library,
                color: AppColors.PRIMARY_COLOR,
                size: dp(context, 30),
              )
            : SizedBox(),
        onTap: () {
          buttomsheet(context: context, controller: controller, isvideo: 2);
        },
      ),
      SizedBox(height: hp(1)),
      controller.ischangepage == null || controller.retagging != null
          ? SizedBox()
          : customRow(
              videoicon: false,
              isvideoimag: false,
              context: context,
              controller: controller,
              textdata: "Cut Ear",
              childimage: controller.selectedearcut.value != null
                  ? GestureDetector(
                      onTap: () {
                        if (controller.selectedearcut.value != null) {
                          showImagePreview(
                            context,
                            controller.selectedearcut.value!,
                          );
                        }
                      },
                      child: Image.file(
                        controller.selectedearcut.value!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox(),

              image: controller.ischangepage == null
                  ? "assets/Tagging_Sample/100779925870a.jpg"
                  : controller.retagging != null
                  ? "assets/Tagging_Sample/100779925870a.jpg"
                  : "assets/Claim_Sample/100291577351f.jpeg",
              onTap: () {
                buttomsheet(
                  context: context,
                  controller: controller,
                  isimage: 11,
                );
              },
            ),
      controller.ischangepage == null || controller.retagging != null
          ? SizedBox()
          : SizedBox(height: hp(1)),
      controller.ischangepage == null || controller.retagging != null
          ? SizedBox()
          : customRow(
              videoicon: false,
              isvideoimag: false,
              context: context,
              controller: controller,
              textdata: "Ear Back Side",
              childimage: controller.selectedearbackside.value != null
                  ? GestureDetector(
                      onTap: () {
                        if (controller.selectedearbackside.value != null) {
                          showImagePreview(
                            context,
                            controller.selectedearbackside.value!,
                          );
                        }
                      },
                      child: Image.file(
                        controller.selectedearbackside.value!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox(),

              image: controller.ischangepage == null
                  ? "assets/Tagging_Sample/100779925870a.jpg"
                  : controller.retagging != null
                  ? "assets/Tagging_Sample/100779925870a.jpg"
                  : "assets/Claim_Sample/100291577351j.jpeg",
              onTap: () {
                buttomsheet(
                  context: context,
                  controller: controller,
                  isimage: 12,
                );
              },
            ),
      controller.ischangepage == null || controller.retagging != null
          ? SizedBox()
          : SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Other",
        childimage: controller.selectedOther5.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedOther5.value != null) {
                    showImagePreview(context, controller.selectedOther5.value!);
                  }
                },
                child: Image.file(
                  controller.selectedOther5.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),

        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 6);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Other",
        childimage: controller.selectedOther1.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedOther1.value != null) {
                    showImagePreview(context, controller.selectedOther1.value!);
                  }
                },
                child: Image.file(
                  controller.selectedOther1.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),

        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 7);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Other",
        childimage: controller.selectedOther2.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedOther2.value != null) {
                    showImagePreview(context, controller.selectedOther2.value!);
                  }
                },
                child: Image.file(
                  controller.selectedOther2.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 8);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Other",
        childimage: controller.selectedOther3.value != null
            ? GestureDetector(
                onTap: () {
                  if (controller.selectedOther3.value != null) {
                    showImagePreview(context, controller.selectedOther3.value!);
                  }
                },
                child: Image.file(
                  controller.selectedOther3.value!,
                  fit: BoxFit.cover,
                ),
              )
            : SizedBox(),
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 9);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Extra Photo",
        childimage: controller.extraPhotos.isNotEmpty
            ? Icon(
                Icons.image,
                color: AppColors.PRIMARY_COLOR,
                size: dp(context, 30),
              )
            : const SizedBox(),
        onTap: () {
          controller.pickExtraPhotos();
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: true,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Extra Video 1",

        childimage: controller.extraVideo1 != null
            ? Icon(
                Icons.video_library,
                color: AppColors.PRIMARY_COLOR,
                size: dp(context, 30),
              )
            : const SizedBox(),

        onTap: () {
          controller.pickExtraVideo(1);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: true,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Extra Video 2",

        childimage: controller.extraVideo2 != null
            ? Icon(
                Icons.video_library,
                color: AppColors.PRIMARY_COLOR,
                size: dp(context, 30),
              )
            : const SizedBox(),

        onTap: () {
          controller.pickExtraVideo(2);
        },
      ),
    ],
  );
}

void showImagePreview(BuildContext context, File imageFile) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.file(imageFile, fit: BoxFit.contain),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    ),
  );
}
