import 'package:get/get.dart';
import 'package:rrm/pages/kyc/kyc_controller.dart';

class KycBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycController>(() => KycController());
  }
}
