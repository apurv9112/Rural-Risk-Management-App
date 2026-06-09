import 'package:get/get.dart';
import 'draft_dashboard_controller.dart';

class DraftDashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DraftDashboardController>(() => DraftDashboardController());
  }
}
