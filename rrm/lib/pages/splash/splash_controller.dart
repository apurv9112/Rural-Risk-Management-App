import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'dart:async';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rrm/services/auth_service.dart';

class SplashController extends GetxController {
  final AppController appController = Get.find();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  Future<void> _startSplash() async {
    // try {
    //   await _audioPlayer.setVolume(1);
    //   await _audioPlayer.play(AssetSource('sounds/cow.mp3'));
    // } catch (e) {
    //   print("Sound error: $e");
    // }

    await Future.delayed(const Duration(seconds: 3));
    Get.snackbar(
      "Splash Debug",
      "Token Empty: ${appController.token.value.isEmpty}",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
    await Future.delayed(const Duration(seconds: 2));

    final token = appController.token.value;

    if (token.isEmpty) {
      Get.offAllNamed(routeLoginpage);
    } else {
      Get.offAllNamed(routehomepage);
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
