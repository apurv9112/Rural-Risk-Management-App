import 'package:get/get.dart';
import 'package:rrm/pages/signature/signature_controller.dart';

class SignatureBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignatureControllerX>(() => SignatureControllerX());
  }
}
