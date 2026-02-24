import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/data_display/data_display_controller.dart';
import 'package:rrm/pages/home/home_page.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';

class OwnerDatadisplaypage extends StatelessWidget {
  final dynamic dataList;
  const OwnerDatadisplaypage({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DatadisplayController>(
      init: DatadisplayController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: 'Owner Cattle Data',
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
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: EdgeInsets.only(right: wp(2), left: wp(4), top: hp(1)),
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
                      listdata: (dataList["ownerName"] ?? dataList["name"] ?? "").toString(),
                    ),
                    datarow(
                      context: context,
                      staticdata: "Mobile - ",
                      listdata: (dataList["mobileNo"] ?? dataList["mobile"] ?? "").toString(),
                    ),
                    datarow(
                      context: context,
                      staticdata: "Village - ",
                      listdata: (dataList["village"] ?? "").toString(),
                    ),
                    datarow(
                      context: context,
                      staticdata: "Taluko - ",
                      listdata: (dataList["taluko"] ?? "").toString(),
                    ),
                    datarow(
                      context: context,
                      staticdata: "Dist - ",
                      listdata: (dataList["district"] ?? dataList["dist"] ?? "").toString(),
                    ),
                    datarow(
                      context: context,
                      staticdata: "Bank - ",
                      listdata: (dataList["bankName"] ?? dataList["bank"] ?? "").toString(),
                    ),
                    datarow(
                      context: context,
                      staticdata: "Branch - ",
                      listdata: (dataList["branchOfBank"] ?? dataList["branch"] ?? "").toString(),
                    ),
                    datarow(
                      context: context,
                      staticdata: "Loan A/C No - ",
                      listdata: (dataList["loanAccountNo"] ?? dataList["loan_a/c_no"] ?? "").toString(),
                    ),
                    datarow(
                      context: context,
                      staticdata: "Insurance - ",
                      listdata: (dataList["insuranceCompanyName"] ?? dataList["Insurance"] ?? "").toString(),
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
                            (dataList["address"] ?? "").toString(),
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
                      mainAxisAlignment: MainAxisAlignment.start,
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
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        SizedBox(width: wp(5)),
                        Image.asset(
                          "assets/images/download.png",
                          scale: dp(context, 16),
                        ),
                      ],
                    ),
                    SizedBox(height: hp(1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        SizedBox(width: wp(5)),
                        Image.asset(
                          "assets/images/download.png",
                          scale: dp(context, 16),
                        ),
                      ],
                    ),

                    SizedBox(height: hp(15)),
                    customcontainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: wp(0),
                        vertical: hp(1),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: wp(0)),
                      onTap: () {},
                      logo: 'assets/images/download.png',
                      imgheight: hp(5),

                      rowwidth: wp(1.5),
                      name: "All Certificate Download",
                      fontSize: dp(context, 20),
                      context: context,
                    ),
                  ],
                ),
              ),
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

// https://chatgpt.com/share/69241d76-b204-8002-93a8-18072ecf9c9d for line divide code
