import 'package:get/get.dart';
import 'dart:async';

import 'package:rrm/routes/common/common_app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(Duration(seconds: 5), () {
      Get.offNamed(routeLoginpage); // Navigate to Home screen
    });
  }
}
