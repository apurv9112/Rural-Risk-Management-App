import 'package:get/get.dart';
import 'package:rrm/pages/tagging/tagging_controller.dart';

class TaggingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaggingController>(() => TaggingController());
  }
}
