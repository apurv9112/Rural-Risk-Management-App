import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceController extends GetxController {
  var deviceId = ''.obs;
  var deviceModel = ''.obs;
  var deviceOS = ''.obs;

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
        final androidId = androidInfo.id;
        deviceId.value = androidId.isNotEmpty ? androidId : "Unknown Device ID";

        final androidModel = "${androidInfo.brand} ${androidInfo.model}".trim();
        deviceModel.value =
            androidModel.isNotEmpty ? androidModel : "Unknown Device";

        final androidVersion = "Android ${androidInfo.version.release}".trim();
        deviceOS.value =
            androidVersion.isNotEmpty ? androidVersion : "Android";
      } else if (GetPlatform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final iosId = iosInfo.identifierForVendor ?? '';
        deviceId.value = iosId.isNotEmpty ? iosId : "Unknown Device ID";

        final iosModel = iosInfo.utsname.machine.toString().trim();
        deviceModel.value = iosModel.isNotEmpty ? iosModel : "Unknown Device";

        final iosVersion = "iOS ${iosInfo.systemVersion}".trim();
        deviceOS.value = iosVersion.isNotEmpty ? iosVersion : "iOS";
      }
    } catch (e) {
      deviceId.value = "Error getting ID";
      deviceModel.value = "Unknown Device";
      deviceOS.value = "Unknown OS";
    }
  }
}
