import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/pages/tagging/tagging_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/text_field.dart';

class TaggingScreen extends StatelessWidget {
  const TaggingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaggingController>(
      init: TaggingController(),
      builder: (controller) {
        print("tagging data :::::::  ${controller.taggings.length}");
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: 'Cattle Tagging',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: Form(
                key: controller.formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: hp(4),
                    right: wp(4),
                    left: wp(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: controller.mobilecontroller,
                        hint: 'Mobile Number',
                        labeltext: 'Mobile Number',
                        onchange: (p0) => controller.mobilecontroller,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: hp(2)),
                      CustomTextField(
                        controller: controller.loanaccoutnumbercontroller,
                        hint: 'Proposal / Loan Account No',
                        labeltext: 'Proposal / Loan Account No',
                        onchange: (p0) => controller.loanaccoutnumbercontroller,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: hp(2)),
                      CustomTextField(
                        controller: controller.nameofcattleownercontroller,
                        hint: 'Name of Cattle Owner',
                        labeltext: 'Name of Cattle Owner',
                        onchange: (p0) =>
                            controller.nameofcattleownercontroller,

                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: hp(2)),
                      CustomTextField(
                        textInputAction: TextInputAction.next,
                        controller: controller.villagecontroller,
                        hint: 'Village',
                        labeltext: 'Village',
                        onchange: (p0) => controller.villagecontroller,
                      ),
                      SizedBox(height: hp(2)),
                      CustomTextField(
                        textInputAction: TextInputAction.next,
                        controller: controller.talukacontroller,
                        hint: 'Taluka',
                        labeltext: 'Taluka',
                        onchange: (p0) => controller.talukacontroller,
                      ),
                      SizedBox(height: hp(2)),
                      CustomTextField(
                        textInputAction: TextInputAction.done,
                        controller: controller.distcontroller,
                        hint: 'District',
                        labeltext: 'District',
                        onchange: (p0) => controller.distcontroller,
                      ),
                      SizedBox(height: hp(3)),

                      Customcontainer(
                        context: context,
                        text: "Search",
                        singlefontSize: dp(context, 25),
                        onTap: () {
                          if (controller.formKey.currentState!.validate()) {
                            controller.search();
                          }
                        },
                      ),

                      SizedBox(height: hp(4)),
                      controller.listshow == false
                          ? Container(
                              height: hp(5.5),
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                right: wp(2),
                                left: wp(4),
                                top: hp(0.5),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.DARK),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.WHITE,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "${controller.taggings.length}",
                                    style: TextStyle(
                                      fontSize: dp(context, 17),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: wp(2)),
                                  SizedBox(
                                    height: hp(12),
                                    child: VerticalDivider(
                                      color: AppColors.LIGHT_GREY,
                                    ),
                                  ),
                                  SizedBox(width: wp(2)),
                                  Text(
                                    'Total Padding Request',
                                    style: TextStyle(
                                      fontSize: dp(context, 17),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      SizedBox(height: hp(2)),
                      controller.listshow == false
                          ? Container(
                              height: hp(5.5),
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                right: wp(2),
                                left: wp(4),
                                top: hp(0.5),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.DARK),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.WHITE,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "NO",
                                    style: TextStyle(
                                      fontSize: dp(context, 17),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: wp(1)),
                                  SizedBox(
                                    height: hp(10),
                                    child: VerticalDivider(
                                      color: AppColors.LIGHT_GREY,
                                    ),
                                  ),
                                  SizedBox(width: wp(2)),
                                  Text(
                                    'Cattle Owner Details',
                                    style: TextStyle(
                                      fontSize: dp(context, 17),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),

                      controller.listshow == false
                          ? SizedBox(height: hp(2))
                          : SizedBox(),

                      controller.listshow == false
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  controller.taggings.length +
                                  (controller.hasMoreData ? 1 : 0),

                              itemBuilder: (context, i) {
                                /// PAGINATION LOADER
                                if (i == controller.taggings.length) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child:
                                          LoadingAnimationWidget.staggeredDotsWave(
                                            color: Colors.white,
                                            size: 60,
                                          ),
                                    ),
                                  );
                                }

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(
                                          routetaggingdatapage,
                                          arguments: {
                                            "tagging": controller.taggings[i],
                                          },
                                        );
                                      },

                                      child: Container(
                                        height: hp(16),
                                        width: double.infinity,
                                        padding: EdgeInsets.only(
                                          right: wp(2),
                                          left: wp(4),
                                          top: hp(1),
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.DARK,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: AppColors.WHITE,
                                        ),

                                        child: Row(
                                          children: [
                                            SizedBox(width: wp(2)),

                                            Center(
                                              child: Text(
                                                "${i + 1}",

                                                style: TextStyle(
                                                  fontSize: dp(context, 18),
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: wp(2.2)),

                                            SizedBox(
                                              height: hp(12),

                                              child: VerticalDivider(
                                                color: AppColors.LIGHT_GREY,
                                              ),
                                            ),

                                            SizedBox(width: wp(2.2)),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  Text(
                                                    controller
                                                            .taggings[i]["ownerName"] ??
                                                        "",

                                                    maxLines: 1,

                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),

                                                  Text(
                                                    controller
                                                            .taggings[i]["mobileNo"] ??
                                                        "",

                                                    maxLines: 1,

                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),

                                                  Text(
                                                    controller
                                                            .taggings[i]["village"] ??
                                                        "",

                                                    maxLines: 1,

                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),

                                                  Text(
                                                    controller
                                                            .taggings[i]["district"] ??
                                                        "",

                                                    maxLines: 1,

                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),

                                                  Text(
                                                    controller
                                                            .taggings[i]["insuranceCompanyName"] ??
                                                        "",

                                                    maxLines: 2,

                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: hp(1.5)),
                                  ],
                                );
                              },
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.WHITE,
            onPressed: () {
              Get.toNamed(
                routetaggingdatapage,
                arguments: {"manualtagging": controller.manualtagging},
              );
            },
            label: Text("Manual Tagging"),
          ),
        );
      },
    );
  }
}
