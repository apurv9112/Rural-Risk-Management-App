import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/home/home_page.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';

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
            ),

            child: Text(
              "RRM DATA BASE",
              style: TextStyle(
                fontSize: dp(context, 22),
                color: AppColors.PRIMARY_COLOR,
                fontWeight: FontWeight.w500,
              ),
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
          logo: 'asset/images/home_logo_1.png',
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
          logo: 'asset/images/home_logo_2.png',
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
          logo: 'asset/images/home_logo_3.png',
          rowwidth: wp(1.5),
          name: "CATTLE \nRETAGGING",
          context: context,
        ),
        SizedBox(height: hp(24)),
        Image.asset(
          'asset/images/splash_logo.png',
          height: hp(5),
          color: AppColors.PRIMARY_COLOR,
        ),
      ],
    ),
  );
}
