import 'package:flutter/material.dart';
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
        childimage:
            controller.isimage == 1 || controller.selectedeartag.value != null
            ? Image.file(controller.selectedeartag.value!, fit: BoxFit.cover)
            : SizedBox(),

        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870a.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870a.jpg"
            : "assets/Claim_Sample/340124808390a.jpg",
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
        childimage:
            controller.isimage == 2 || controller.selectedheadpose.value != null
            ? Image.file(controller.selectedheadpose.value!, fit: BoxFit.cover)
            : SizedBox(),
        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870b.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870b.jpg"
            : "assets/Claim_Sample/340124808390b.jpg",
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
        childimage:
            controller.isimage == 3 ||
                controller.selectedsideposeleft.value != null
            ? Image.file(
                controller.selectedsideposeleft.value!,
                fit: BoxFit.cover,
              )
            : SizedBox(),
        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870c.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870c.jpg"
            : "assets/Claim_Sample/340124808390c.jpg",
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
        textdata: "Side Pose 2(Right)",
        childimage:
            controller.isimage == 4 ||
                controller.selectedsideposeright.value != null
            ? Image.file(
                controller.selectedsideposeright.value!,
                fit: BoxFit.cover,
              )
            : SizedBox(),
        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870d.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870d.jpg"
            : "assets/Claim_Sample/340124808390d.jpg",
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 4);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: false,
        isvideoimag: false,
        context: context,
        controller: controller,
        textdata: "Back Pose",
        childimage:
            controller.isimage == 5 || controller.selectedbackpose.value != null
            ? Image.file(controller.selectedbackpose.value!, fit: BoxFit.cover)
            : SizedBox(),
        image: controller.ischangepage == null
            ? "assets/Tagging_Sample/100779925870e.jpg"
            : controller.retagging != null
            ? "assets/Tagging_Sample/100779925870e.jpg"
            : "assets/Claim_Sample/340124808390e.jpg",
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 5);
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
          buttomsheet(context: context, controller: controller, isimage: 1);
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
          buttomsheet(context: context, controller: controller, isimage: 2);
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
              childimage:
                  controller.isimage == 11 ||
                      controller.selectedearcut.value != null
                  ? Image.file(
                      controller.selectedearcut.value!,
                      fit: BoxFit.cover,
                    )
                  : SizedBox(),

              image: controller.ischangepage == null
                  ? "assets/Tagging_Sample/100779925870a.jpg"
                  : controller.retagging != null
                  ? "assets/Tagging_Sample/100779925870a.jpg"
                  : "assets/Claim_Sample/340124808390a.jpg",
              onTap: () {
                buttomsheet(
                  context: context,
                  controller: controller,
                  isimage: 1,
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
              childimage:
                  controller.isimage == 11 ||
                      controller.selectedearbackside.value != null
                  ? Image.file(
                      controller.selectedearbackside.value!,
                      fit: BoxFit.cover,
                    )
                  : SizedBox(),

              image: controller.ischangepage == null
                  ? "assets/Tagging_Sample/100779925870a.jpg"
                  : controller.retagging != null
                  ? "assets/Tagging_Sample/100779925870a.jpg"
                  : "assets/Claim_Sample/340124808390a.jpg",
              onTap: () {
                buttomsheet(
                  context: context,
                  controller: controller,
                  isimage: 1,
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
        childimage:
            controller.isimage == 6 || controller.selectedOther5.value != null
            ? Image.file(controller.selectedOther5.value!, fit: BoxFit.cover)
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
        childimage:
            controller.isimage == 7 || controller.selectedOther1.value != null
            ? Image.file(controller.selectedOther1.value!, fit: BoxFit.cover)
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
        childimage:
            controller.isimage == 8 || controller.selectedOther2.value != null
            ? Image.file(controller.selectedOther2.value!, fit: BoxFit.cover)
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
        childimage:
            controller.isimage == 9 || controller.selectedOther2.value != null
            ? Image.file(controller.selectedOther2.value!, fit: BoxFit.cover)
            : SizedBox(),
        onTap: () {
          buttomsheet(context: context, controller: controller, isimage: 9);
        },
      ),
      SizedBox(height: hp(1)),
      customRow(
        videoicon: true,
        isvideoimag: true,
        context: context,
        controller: controller,
        textdata: "Extra Video & Photo",
        childimage: controller.galleryFiles.isNotEmpty
            ? Icon(
                Icons.video_library,
                color: AppColors.PRIMARY_COLOR,
                size: dp(context, 30),
              )
            : SizedBox(),
        onTap: () {
          controller.pickMultiplePhotosAndVideos();
        },
      ),
    ],
  );
}
