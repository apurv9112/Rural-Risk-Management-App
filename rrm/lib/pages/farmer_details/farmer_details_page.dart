import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';
import 'package:rrm/pages/home/home_page.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:screenshot/screenshot.dart';

class FarmerDetailsScreen extends StatelessWidget {
  const FarmerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FarmerDetailsController>(
      init: FarmerDetailsController(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: 'Report',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
          ),
          body: Padding(
            padding: EdgeInsets.only(
              top: hp(4),
              right: wp(4),
              left: wp(4),
              bottom: hp(4),
            ),
            child: Stack(
              children: [
                Screenshot(
                  controller: controller.screenshotController,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      right: wp(4),
                      left: wp(4),
                      top: hp(1),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.DARK),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.WHITE,
                    ),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: hp(0.5)),

                          Center(
                            child: Text(
                              controller.type == "claim"
                                  ? "CLAIM REPORT"
                                  : controller.type == "retagging"
                                  ? "RETAGGING REPORT"
                                  : controller.type == "tagging"
                                  ? "TAGGING REPORT"
                                  : "",
                              style: TextStyle(
                                fontSize: dp(context, 24),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: hp(1)),

                          datarow(
                            context: context,
                            staticdata: "Pera-Wet - ",
                            listdata:
                                controller.appController.userName.value ?? "",
                          ),
                          datarow(
                            context: context,
                            staticdata: "Name - ",
                            listdata: controller.report["owner"]?["name"] ?? "",
                          ),
                          datarow(
                            context: context,
                            staticdata: "Lan Number - ",
                            listdata:
                                controller.report["owner"]?["lanNumber"] ?? "",
                          ),
                          datarow(
                            context: context,
                            staticdata: "Mobile - ",
                            listdata:
                                controller.report["owner"]?["mobile"] ?? "",
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Address - ",
                                style: TextStyle(
                                  fontSize: dp(context, 18),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: wp(60),
                                child: Text(
                                  controller.report["owner"]?["address"] ?? "",
                                  style: TextStyle(
                                    fontSize: dp(context, 18),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: hp(2)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sr\nNo.",
                                style: TextStyle(
                                  fontSize: dp(context, 20),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: wp(3)),
                              Text(
                                "Tag Num.",
                                style: TextStyle(
                                  fontSize: dp(context, 20),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: wp(3)),
                              Text(
                                "Species",
                                style: TextStyle(
                                  fontSize: dp(context, 20),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: wp(3)),
                              Text(
                                "Sum Ins.",
                                style: TextStyle(
                                  fontSize: dp(context, 20),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: hp(1)),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                (controller.report["cattle"] as List?)
                                    ?.length ??
                                0,
                            itemBuilder: (context, index) {
                              final item =
                                  ((controller.report["cattle"] as List?) ??
                                          [])[index]
                                      as Map<String, dynamic>;

                              return Padding(
                                padding: EdgeInsets.only(bottom: hp(1)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: wp(1)),

                                    SizedBox(
                                      width: wp(5),
                                      child: Text(
                                        "${item["srNo"] ?? index + 1}",
                                        style: TextStyle(
                                          fontSize: dp(context, 18),
                                          fontWeight: FontWeight.w300,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    SizedBox(width: wp(5)),

                                    SizedBox(
                                      width: wp(19),
                                      child: Text(
                                        "${item["tagNo"] ?? ""}",
                                        style: TextStyle(
                                          fontSize: dp(context, 18),
                                          fontWeight: FontWeight.w300,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    SizedBox(width: wp(5)),

                                    SizedBox(
                                      width: wp(15),
                                      child: Text(
                                        "${item["species"] ?? ""}",
                                        style: TextStyle(
                                          fontSize: dp(context, 18),
                                          fontWeight: FontWeight.w300,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    SizedBox(width: wp(4)),

                                    SizedBox(
                                      width: wp(18),
                                      child: Text(
                                        "${item["sumInsured"] ?? ""}",
                                        style: TextStyle(
                                          fontSize: dp(context, 18),
                                          fontWeight: FontWeight.w300,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  bottom: hp(-60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customcontainer(
                        padding: EdgeInsets.only(
                          right: wp(3),
                          top: hp(1),
                          bottom: hp(1),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: wp(0)),
                        onTap: () async {
                          await controller.shareScreenshot();
                        },
                        logo: 'assets/images/share.png',
                        imgheight: hp(5),

                        rowwidth: wp(1),
                        name: "Share",
                        fontSize: dp(context, 20),
                        context: context,
                      ),
                      SizedBox(width: wp(2)),
                      customcontainer(
                        padding: EdgeInsets.only(
                          right: wp(3),
                          top: hp(1),
                          bottom: hp(1),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: wp(0)),
                        onTap: () {
                          Get.offAllNamed("routehomepage");
                        },
                        logo: 'assets/images/home.png',
                        imgheight: hp(5),

                        rowwidth: wp(1.5),
                        name: "Home",
                        fontSize: dp(context, 20),
                        context: context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

datarow({
  required BuildContext context,
  required String staticdata,
  required String listdata,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        staticdata,
        style: TextStyle(
          fontSize: dp(context, 18),
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        listdata,
        style: TextStyle(
          fontSize: dp(context, 18),
          fontWeight: FontWeight.w300,
        ),
      ),
    ],
  );
}
