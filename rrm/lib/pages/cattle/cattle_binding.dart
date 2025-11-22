import 'package:get/get.dart';
import 'package:rrm/pages/cattle/cattle_controller.dart';

class CattleBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CattleController>(() => CattleController());
  }
}
