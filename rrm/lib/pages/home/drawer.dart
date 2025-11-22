import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/home/home_page.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customcontainer.dart';

customdrawer({required BuildContext context}) {
  return Drawer(
    backgroundColor: AppColors.WHITE,
    child: ListView(
      children: [
        SizedBox(
          height: hp(6),
          child: DrawerHeader(
            padding: EdgeInsetsGeometry.only(
              top: hp(1),
              left: wp(5),
              bottom: hp(1),
              right: wp(3),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "RRM DATA BASE",
                  style: TextStyle(
                    fontSize: dp(context, 22),
                    color: AppColors.PRIMARY_COLOR,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialoglogout(context: context);
                  },
                  child: Image.asset(
                    "assets/images/logout.png",
                    color: AppColors.PRIMARY_COLOR,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: hp(2)),
        customcontainer(
          padding: EdgeInsets.symmetric(horizontal: wp(3)),
          margin: EdgeInsets.symmetric(horizontal: wp(4)),
          onTap: () {
            Get.toNamed(routetaggingpage);
          },
          context: context,
          logo: 'assets/images/home_logo_1.png',
          rowwidth: wp(5),
          name: "CATTLE \nTAGGING",
        ),
        SizedBox(height: hp(3)),
        customcontainer(
          padding: EdgeInsets.symmetric(horizontal: wp(3)),
          margin: EdgeInsets.symmetric(horizontal: wp(4)),
          onTap: () {
            Get.toNamed(routeclaimpage);
          },
          logo: 'assets/images/home_logo_2.png',
          rowwidth: wp(6),
          name: 'CATTLE \nCLAIM',
          context: context,
        ),
        SizedBox(height: hp(3)),
        customcontainer(
          padding: EdgeInsets.symmetric(horizontal: wp(2)),
          margin: EdgeInsets.symmetric(horizontal: wp(3.5)),
          onTap: () {
            Get.toNamed(routeclaimpage);
            // print("retagging  :::: ${controller.retagging}");
          },
          logo: 'assets/images/home_logo_3.png',
          rowwidth: wp(1.5),
          name: "CATTLE \nRETAGGING",
          context: context,
        ),
        SizedBox(height: hp(24)),
        Image.asset(
          'assets/images/splash_logo.png',
          height: hp(5),
          color: AppColors.PRIMARY_COLOR,
        ),
      ],
    ),
  );
}

void showDialoglogout({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        titleTextStyle: TextStyle(
          color: Colors.red,
          fontSize: dp(context, 24),
          fontStyle: FontStyle.italic,
        ),
        title: Text("Logout", textAlign: TextAlign.center),
        content: Text(
          "Are You Sure You want to Logout.",
          textAlign: TextAlign.center,
        ),
        contentTextStyle: TextStyle(
          fontSize: dp(context, 15),
          color: AppColors.DARK,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Customcontainer(
                onTap: () {
                  Get.offAllNamed('/loginpage');
                },
                context: context,
                width: wp(33),
                text: "Yes",
                textcolor: AppColors.WHITE,
                color: Colors.red,
              ),
              SizedBox(width: wp(2)),
              Customcontainer(
                onTap: () {
                  Get.back();
                },
                width: wp(33),
                context: context,
                text: "No",
                textcolor: AppColors.WHITE,
                color: AppColors.PRIMARY_COLOR,
              ),
            ],
          ),
        ],
      );
    },
  );
}
