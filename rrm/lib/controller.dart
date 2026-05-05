import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  final _box = GetStorage();
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    token.value = _box.read('token') ?? '';
  }

  void setToken(String value) {
    token.value = value;
    _box.write('token', value);
  }

  Future<void> clearToken() async {
    token.value = '';
    await _box.remove('token');
  }

  bool get isLoggedIn => token.value.isNotEmpty;
}
