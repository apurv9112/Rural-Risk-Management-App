import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.PRIMARY_COLOR,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: hp(20)),
            Image.asset(
              'assets/images/splash_logo.png',
              scale: dp(context, 3),
              color: AppColors.WHITE,
            ),
            SizedBox(height: hp(1)),
            Lottie.asset(
              'assets/animations/cow.json',
              width: wp(50),
              height: hp(50),
            ),
          ],
        ),
      ),
    );
  }
}
