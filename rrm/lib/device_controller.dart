import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceController extends GetxController {
  var deviceId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeviceId();
  }

  Future<void> fetchDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (GetPlatform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId.value = androidInfo.id ?? "Unknown Device ID";
      } else if (GetPlatform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId.value = iosInfo.identifierForVendor ?? "Unknown Device ID";
      }
    } catch (e) {
      deviceId.value = "Error getting ID";
    }
  }
}
