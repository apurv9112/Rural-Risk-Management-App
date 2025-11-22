import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/claim/claim_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/text_field.dart';

class ClaimScreen extends StatelessWidget {
  const ClaimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClaimController>(
      init: ClaimController(),
      builder: (controller) {
        final args = Get.arguments;
        print("args ;;;; $args");
        controller.retagging = args != null ? args["retagging"] : null;
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: controller.retagging != null
                ? 'Cattle Retagging'
                : 'Cattle Claim',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: hp(4), right: wp(4), left: wp(4)),
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, i) {
                return Column(
                  children: [
                    CustomTextField(
                      controller: controller.namecontroller,
                      backgroundColor: AppColors.WHITE,
                      inputtextcolor: AppColors.PRIMARY_COLOR,
                      readOnly: true,
                    ),
                    SizedBox(height: hp(2)),
                    Row(
                      children: [
                        Customcontainer(context: context, text: "M:"),
                        SizedBox(width: wp(2.5)),
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: controller.mobilenumbercontroller,
                            backgroundColor: AppColors.WHITE,
                            inputtextcolor: AppColors.PRIMARY_COLOR,
                            readOnly: true,
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
                            controller: controller.addresscontroller,
                            backgroundColor: AppColors.WHITE,
                            inputtextcolor: AppColors.PRIMARY_COLOR,
                            readOnly: true,
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
                            controller: controller.villegcontroller,
                            backgroundColor: AppColors.WHITE,
                            inputtextcolor: AppColors.PRIMARY_COLOR,
                            readOnly: true,
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
                            controller: controller.talukcontroller,
                            backgroundColor: AppColors.WHITE,
                            inputtextcolor: AppColors.PRIMARY_COLOR,
                            readOnly: true,
                          ),
                        ),
                        SizedBox(width: wp(2.5)),
                        Customcontainer(context: context, text: "Di:"),
                        SizedBox(width: wp(2.5)),
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: controller.districcontroller,
                            backgroundColor: AppColors.WHITE,
                            inputtextcolor: AppColors.PRIMARY_COLOR,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: hp(2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Customcontainer(
                          context: context,
                          text: "Species",
                          height: hp(4.5),
                          width: wp(30),
                          padding: EdgeInsets.only(
                            left: wp(2.5),
                            right: wp(2.5),
                          ),
                        ),
                        SizedBox(width: wp(2)),
                        Customcontainer(
                          width: wp(60),
                          context: context,
                          text: "Tag Number",
                          height: hp(4.5),
                          padding: EdgeInsets.only(
                            left: wp(2.5),
                            right: wp(2.5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: hp(2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Customcontainer(
                          context: context,
                          text: "Buffalo",
                          height: hp(4.5),
                          width: wp(30),
                          padding: EdgeInsets.only(
                            left: wp(2.5),
                            right: wp(2.5),
                          ),
                        ),
                        SizedBox(width: wp(2)),
                        Customcontainer(
                          width: wp(60),
                          context: context,
                          text: "4123421554415",
                          height: hp(4.5),
                          padding: EdgeInsets.only(
                            left: wp(2.5),
                            right: wp(2.5),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: hp(3)),
                    Customcontainer(
                      onTap: () {
                        Get.toNamed(
                          routetaggingdatapage,
                          arguments: {
                            "isclaim": controller.claim,
                            "retagging": controller.retagging,
                          },
                        );
                      },
                      context: context,
                      width: double.infinity,
                      text: controller.retagging != null
                          ? "Attend Retagging"
                          : "Attend Claim",
                      singlefontSize: dp(context, 25),
                      padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                    ),
                    SizedBox(height: hp(8)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
