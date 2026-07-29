import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  final _box = GetStorage();
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    token.value = _box.read('token') ?? '';

    Get.snackbar(
      "Debug",
      "Saved Token: ${token.value.isEmpty ? "EMPTY" : token.value}",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
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

  RxString userName = "".obs;
  RxString mobileNumber = "".obs;
  RxString email = "".obs;

  /// SAVE USER DATA
  void saveUserData({
    required String name,
    required String mobile,
    required String emailId,
  }) {
    userName.value = name;
    mobileNumber.value = mobile;
    email.value = emailId;

    _box.write("userName", name);
    _box.write("mobileNumber", mobile);
    _box.write("email", emailId);
  }

  /// LOAD USER DATA
  void loadUserData() {
    userName.value = _box.read("userName") ?? "";
    mobileNumber.value = _box.read("mobileNumber") ?? "";
    email.value = _box.read("email") ?? "";
  }

  /// CLEAR USER DATA
  void clearUserData() {
    _box.erase();

    userName.value = "";
    mobileNumber.value = "";
    email.value = "";
  }
}
