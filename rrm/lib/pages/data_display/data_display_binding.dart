import 'package:get/get.dart';
import 'package:rrm/pages/data_display/data_display_controller.dart';

class DatadisplayBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DatadisplayController>(() => DatadisplayController());
  }
}
