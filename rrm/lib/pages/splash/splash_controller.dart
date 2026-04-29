// import 'package:get/get.dart';
// import 'package:rrm/controller.dart';
// import 'dart:async';

// import 'package:rrm/routes/common/common_app_pages.dart';

// class SplashController extends GetxController {
//   final AppController appController = Get.find();
//   @override
//   void onInit() {
//     super.onInit();
//     Timer(const Duration(seconds: 5), () {
//       if (appController.isLoggedIn) {
//         Get.offAllNamed(routehomepage);
//       } else {
//         Get.offAllNamed(routeLoginpage);
//       }
//     });
//   }
// }
import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'dart:async';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:audioplayers/audioplayers.dart';

class SplashController extends GetxController {
  final AppController appController = Get.find();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  Future<void> _startSplash() async {
    try {
      await _audioPlayer.setVolume(0.6);
      await _audioPlayer.play(AssetSource('sounds/cow.mp3'));
    } catch (e) {
      print("Sound error: $e");
    }

    Timer(const Duration(seconds: 5), () {
      if (appController.isLoggedIn) {
        Get.offAllNamed(routehomepage);
      } else {
        Get.offAllNamed(routeLoginpage);
      }
    });
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
