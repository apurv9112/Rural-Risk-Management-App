import 'package:get/get.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';

class FarmerDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerDetailsController>(() => FarmerDetailsController());
  }
}
