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
            title: 'Cattle Claim',
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
                          datarow(
                            context: context,
                            staticdata: "Name - ",
                            listdata: "Apurv Patel",
                          ),
                          datarow(
                            context: context,
                            staticdata: "Addher Number - ",
                            listdata: "458962578452",
                          ),
                          datarow(
                            context: context,
                            staticdata: "Lan Number - ",
                            listdata: "41578962214",
                          ),
                          datarow(
                            context: context,
                            staticdata: "Mobile - ",
                            listdata: "5485236852",
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
                                  "B-TF-7, Block - B, Third Floor, Signet Plaza Kunal Char Rasta Gotri Road Samta, Gotri Vadodara, Gujarat 390021 India",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: wp(1)),
                              SizedBox(
                                width: wp(5),
                                child: Text(
                                  "1",
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
                                  "986521\n478945",
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
                                  "Cow",
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
                                  "45000",
                                  style: TextStyle(
                                    fontSize: dp(context, 18),
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: hp(1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: wp(1)),
                              SizedBox(
                                width: wp(5),
                                child: Text(
                                  "2",
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
                                  "412587\n986325",
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
                                  "Buffalo",
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
                                  "50000",
                                  style: TextStyle(
                                    fontSize: dp(context, 18),
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
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
                          Get.offAllNamed("/homepage");
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
