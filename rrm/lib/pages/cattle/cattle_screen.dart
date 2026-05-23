import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rrm/pages/cattle/cattle_controller.dart';
import 'package:rrm/pages/cattle/widget/cattle_image.dart';
import 'package:rrm/pages/cattle/widget/cattle_species.dart';
import 'package:rrm/pages/cattle/widget/cattle_specifications.dart';
import 'package:rrm/pages/cattle/widget/custom_dropdown.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/text_field.dart';

class Cattlescreen extends StatelessWidget {
  const Cattlescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CattleController>(
      builder: (controller) {
        final Map<String, dynamic> args =
            (Get.arguments as Map<String, dynamic>?) ?? {};
        if (controller.data == null) {
          controller.syncFromArgs(args);
        }

        controller.taggingdatecontroller.text = DateFormat(
          'yyyy-MM-dd',
        ).format(controller.selectedDate.value!);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: controller.ischangepage == null
                ? 'CATTLE ${controller.currentCattleIndex}/${controller.totalCattleCount}'
                : controller.retagging != null
                ? 'CATTLE RETAGGING'
                : 'CATTLE CLAIM',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
          ),
          body: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: hp(4), right: wp(4), left: wp(4)),
              child: Column(
                children: [
                  controller.ischangepage == null
                      ? customdropdown(
                          context: context,
                          controller: controller,
                          title: 'Successfully Tagging',
                          value: controller.selectedspeciesnotavailable,
                          items: (controller.speciesnotavailable)
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            controller.selectedspeciesnotavailable = value
                                .toString();
                            // print(
                            //   "aaaa ::: ${controller.selectedspeciesnotavailable}",
                            // );
                            controller.update();
                          },
                        )
                      : SizedBox(),
                  controller.ischangepage == null
                      ? SizedBox(height: hp(1))
                      : SizedBox(),
                  Row(
                    children: [
                      Customcontainer(
                        context: context,
                        text: controller.ischangepage == null
                            ? "Tag Number:"
                            : controller.retagging != null
                            ? "Old Number:"
                            : "Claim Tag number:",
                      ),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          keyboardType: TextInputType.none,
                          controller: controller.tagnumbercontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: controller.ischangepage != null,
                        ),
                      ),
                    ],
                  ),
                  controller.retagging == null
                      ? SizedBox()
                      : SizedBox(height: hp(1)),
                  controller.retagging == null
                      ? SizedBox()
                      : Row(
                          children: [
                            Customcontainer(
                              context: context,
                              text: "New Number:",
                            ),
                            SizedBox(width: wp(2.5)),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                keyboardType: TextInputType.number,
                                controller: controller.newtagnumbercontroller,
                                backgroundColor: AppColors.WHITE,
                                inputtextcolor: AppColors.PRIMARY_COLOR,
                                readOnly: false,
                              ),
                            ),
                          ],
                        ),
                  controller.ischangepage == null ||
                          controller.retagging != null
                      ? SizedBox(height: hp(1))
                      : SizedBox(),
                  controller.retagging != null ||
                          controller.ischangepage == null
                      ? Row(
                          children: [
                            Customcontainer(
                              context: context,
                              text: "Tagging Date:",
                            ),
                            SizedBox(width: wp(2.5)),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller: controller.taggingdatecontroller,
                                inputtextcolor: AppColors.PRIMARY_COLOR,
                                readOnly: true,
                                backgroundColor: AppColors.WHITE,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    controller.retagging != null
                                        ? controller.pickDate(
                                            controller: controller,
                                            context,
                                          )
                                        : SizedBox();
                                  },
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.PRIMARY_COLOR,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  controller.ischangepage != null &&
                          controller.retagging != null
                      ? SizedBox(height: hp(1))
                      : SizedBox(),
                  controller.ischangepage != null &&
                          controller.retagging != null
                      ? Row(
                          children: [
                            Customcontainer(
                              context: context,
                              text: "New Tagging Date:",
                            ),
                            SizedBox(width: wp(2.5)),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller: controller.taggingdatecontroller,
                                inputtextcolor: AppColors.PRIMARY_COLOR,
                                readOnly: true,
                                backgroundColor: AppColors.WHITE,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    controller.taggingdate = true;
                                    controller.pickDate(
                                      controller: controller,
                                      context,
                                    );
                                    controller.update();
                                  },
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.PRIMARY_COLOR,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),

                  controller.ischangepage == null
                      ? SizedBox(height: hp(1))
                      : SizedBox(),

                  controller.ischangepage == null
                      ? iscattlespecifications(
                          context: context,
                          controller: controller,
                        )
                      : SizedBox(),
                  iscattlevalue(context: context, controller: controller),
                  SizedBox(height: hp(1)),
                  iscattleimage(context: context, controller: controller),
                  SizedBox(height: hp(2)),
                  Customcontainer(
                    onTap: () {
                      controller.update();
                      if (controller.ischangepage == null) {
                        // Normal tagging flow
                        controller.savecattle();
                      } else if (controller.retagging != null) {
                        // Retagging flow
                        controller.savecattle();
                      } else {
                        // Claim flow
                        controller.saveclaim();
                      }
                    },
                    context: context,
                    text: controller.ischangepage == null
                        ? "Save & Next Cattle"
                        : controller.retagging != null
                        ? "Submit Retagging"
                        : "Submit Claim",
                    singlefontSize: dp(context, 20),
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
