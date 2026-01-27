import 'package:get/get.dart';

class AppController extends GetxController {
  RxString token = ''.obs;

  void setToken(String value) {
    token.value = value;
  }

  void clearToken() {
    token.value = '';
  }
}

