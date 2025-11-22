import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        child: Image.asset(
          'assets/images/splash_logo.png',
          scale: dp(context, 3),
          color: AppColors.WHITE,
        ),
      ),
    );
  }
}
