// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/pages/tagging_data_screen.dart/widget/cancel.dart';
import 'package:rrm/pages/tagging_data_screen.dart/widget/species.dart';
import 'package:rrm/pages/tagging_data_screen.dart/tagging_data_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/text_field.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class TaggingDataScreen extends StatelessWidget {
  const TaggingDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaggingdataController>(
      init: TaggingdataController(),
      builder: (controller) {
        final Map<String, dynamic>? args =
            Get.arguments as Map<String, dynamic>?;
        if (args != null && args.isNotEmpty) {
          controller.setInitialData(args);
          controller.retagging = args["retagging"];
          controller.ischangepage = args["isclaim"];
          controller.manualtagging = args["manualtagging"];
        }

        final dataMap = controller.data as Map<String, dynamic>?;
        if (dataMap == null && controller.manualtagging != true) {
          return const Scaffold(
            body: Center(child: Text("No lead data provided.")),
          );
        }
        // ignore: unnecessary_non_null_assertion
        controller.initFieldsFromData(dataMap!, context);
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: controller.ischangepage == null
                ? 'Cattle Tagging'
                : controller.retagging != null
                ? 'Cattle Retagging'
                : 'Cattle Claim',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: hp(4), right: wp(4), left: wp(4)),
              child: Column(
                children: [
                  CustomTextField(
                    hint: "Owner Name",
                    hintStyle: TextStyle(
                      color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                    ),
                    controller: controller.namecontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: AppColors.PRIMARY_COLOR,
                    readOnly: controller.manualtagging ?? true,
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "M:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "Mobile Number",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.mobilenumbercontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              final number = controller
                                  .mobilenumbercontroller
                                  .text
                                  .trim();
                              if (number.isEmpty) return;
                              url_launcher.launchUrl(Uri.parse('tel:+$number'));
                            },
                            child: Icon(
                              Icons.call_sharp,
                              color: AppColors.PRIMARY_COLOR,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "Add:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "Address",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.addresscontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "Vill:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "Village",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.villegcontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "Ta:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "Taluk",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.talukcontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                        ),
                      ),
                      SizedBox(width: wp(2.5)),
                      Customcontainer(context: context, text: "Di:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "District",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.districcontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "Bank:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "Bank Name",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.banknamecontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "Branch:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "Branch",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.branchcontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "Loan A/c No:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "Loan Account Number",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.loanacnocontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "Insurance Co:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          hint: "Insurance Company",
                          hintStyle: TextStyle(
                            color: AppColors.PRIMARY_COLOR.withOpacity(0.5),
                          ),
                          controller: controller.insurancecontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.manualtagging ?? true,
                        ),
                      ),
                    ],
                  ),
                  controller.ischangepage == null
                      ? SizedBox(height: hp(4))
                      : SizedBox(height: hp(2)),
                  ////////////////////////
                  species(context: context, controller: controller),
                  controller.ischangepage == null
                      ? SizedBox()
                      : SizedBox(height: hp(2)),
                  controller.ischangepage == null
                      ? SizedBox()
                      : Customcontainer(
                          onTap: () {
                            showDialogWithFields(
                              context: context,
                              controller: controller,
                              title: Text(
                                controller.retagging != null
                                    ? "Old Tagging Photo"
                                    : "Tagging Photo",
                                style: TextStyle(
                                  color: AppColors.PRIMARY_COLOR,
                                  fontSize: dp(context, 20),
                                ),
                              ),
                              content: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),

                                child: SizedBox(
                                  height: hp(78),
                                  width: wp(70),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: controller.imageBytesList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: hp(2)),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.PRIMARY_COLOR,
                                            width: wp(1),
                                          ),
                                        ),
                                        child: InteractiveViewer(
                                          minScale: 1,
                                          maxScale: 4,
                                          child: Image.memory(
                                            controller.imageBytesList[index],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              actions: [],
                            );
                          },
                          context: context,
                          text: controller.retagging != null
                              ? "Old Tagging Photo"
                              : "Tagging Photo",
                          icon: Icons.image_rounded,
                        ),
                  controller.ischangepage == null
                      ? SizedBox()
                      : SizedBox(height: hp(2)),
                  controller.ischangepage == null
                      ? SizedBox()
                      : Row(
                          children: [
                            Customcontainer(
                              context: context,
                              text: controller.retagging != null
                                  ? "Date of Retagging:"
                                  : "Date of Death:",
                            ),
                            SizedBox(width: wp(2.5)),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller: controller.dateofdeathcontroller,
                                inputtextcolor: AppColors.PRIMARY_COLOR,
                                readOnly: true,
                                backgroundColor: AppColors.WHITE,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    controller.pickDate(
                                      controller: controller,
                                      context,
                                    );
                                  },
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.PRIMARY_COLOR,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  controller.ischangepage == null
                      ? SizedBox()
                      : SizedBox(height: hp(2)),
                  controller.ischangepage == null
                      ? SizedBox()
                      : Row(
                          children: [
                            Customcontainer(
                              context: context,
                              text: controller.retagging != null
                                  ? "New Tag No:"
                                  : "Time of Death:",
                            ),
                            SizedBox(width: wp(2.5)),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                keyboardType: TextInputType.number,
                                controller: controller.timeofdeathcontroller,
                                inputtextcolor: AppColors.PRIMARY_COLOR,
                                readOnly: controller.retagging != null
                                    ? false
                                    : true,
                                backgroundColor: AppColors.WHITE,
                                suffixIcon: controller.retagging != null
                                    ? null
                                    : GestureDetector(
                                        onTap: () {
                                          controller.pickTime(
                                            controller: controller,
                                            context,
                                          );
                                        },
                                        child: Icon(
                                          Icons.access_time,
                                          color: AppColors.PRIMARY_COLOR,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: hp(3)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Customcontainer(
                        onTap: () {
                          showDialogWithFields(
                            context: context,
                            controller: controller,
                          );
                        },
                        context: context,
                        width: wp(44),
                        text: controller.ischangepage == null
                            ? "Lead Cancel"
                            : controller.retagging != null
                            ? "RT Cancel"
                            : "Claim Cancel",
                        icon: Icons.cancel_presentation_sharp,
                        padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                      ),
                      SizedBox(width: wp(3)),
                      Customcontainer(
                        onTap: () async {
                          controller.syncDataFromControllers();

                          Get.dialog(
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                  SizedBox(height: hp(0.5)),
                                  Text(
                                    "Please wait...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: dp(context, 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            barrierColor: Colors.black45,
                            barrierDismissible: false,
                          );

                          await controller.saveLeadUpdates();

                          if (Get.isDialogOpen ?? false) Get.back();
                          Get.toNamed(
                            routekycpage,
                            arguments: {
                              "tagging": controller.data,
                              "ischangepage": controller.ischangepage,
                              "retagging": controller.retagging,
                            },
                          );
                        },
                        context: context,
                        width: wp(44),
                        text: "Next",
                        icon: Icons.arrow_forward_sharp,
                        padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                      ),
                    ],
                  ),

                  SizedBox(height: hp(3)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
