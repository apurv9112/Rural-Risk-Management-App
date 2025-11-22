import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/home/drawer.dart';
import 'package:rrm/pages/home/home_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          key: controller.scaffoldKey,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: 'Dashboard',
            iconleft: Icons.menu,
            lefticononTap: () {
              controller.scaffoldKey.currentState!.openDrawer();
            },
            iconright: Icons.refresh_outlined,
          ),
          drawer: customdrawer(context: context),
          body: Column(
            children: [
              SizedBox(height: hp(12)),
              customcontainer(
                onTap: () {
                  Get.toNamed(routetaggingpage);
                },
                context: context,
                logo: 'assets/images/home_logo_1.png',
                rowwidth: wp(10),
                name: "CATTLE \nTAGGING",
              ),
              SizedBox(height: hp(3)),
              customcontainer(
                onTap: () {
                  Get.toNamed(routeclaimpage);
                },
                logo: 'assets/images/home_logo_2.png',
                rowwidth: wp(15),
                name: 'CATTLE \nCLAIM',
                context: context,
              ),
              SizedBox(height: hp(3)),
              customcontainer(
                onTap: () {
                  Get.toNamed(
                    routeclaimpage,
                    arguments: {"retagging": controller.retagging},
                  );
                  // print("retagging  :::: ${controller.retagging}");
                },
                logo: 'assets/images/home_logo_3.png',
                rowwidth: wp(7),
                name: "CATTLE \nRETAGGING",
                context: context,
              ),
            ],
          ),
        );
      },
    );
  }
}

customcontainer({
  required String logo,
  required String name,
  required BuildContext context,
  required double? rowwidth,
  required void Function()? onTap,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dp(context, 15)),
        border: Border.all(color: AppColors.DARK),
        color: AppColors.WHITE,
      ),
      padding: padding ?? EdgeInsets.symmetric(horizontal: wp(5)),
      margin: margin ?? EdgeInsets.symmetric(horizontal: wp(6)),
      child: Row(
        children: [
          Image.asset(logo, height: hp(15), width: wp(20)),
          SizedBox(width: rowwidth),
          Text(
            name,
            style: TextStyle(
              fontSize: dp(context, 30),
              color: AppColors.PRIMARY_COLOR,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
