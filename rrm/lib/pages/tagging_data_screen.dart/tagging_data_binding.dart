import 'package:get/get.dart';
import 'package:rrm/pages/tagging_data_screen.dart/tagging_data_controller.dart';

class TaggingDataBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaggingdataController>(() => TaggingdataController());
  }
}
