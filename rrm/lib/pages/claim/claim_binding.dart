import 'package:get/get.dart';
import 'package:rrm/pages/claim/claim_controller.dart';

class ClaimBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClaimController>(() => ClaimController());
  }
}
