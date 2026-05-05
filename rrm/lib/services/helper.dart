import 'package:get/get_connect/http/src/response/response.dart' as http;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:rrm/controller.dart';

Future<http.Response> handleResponse(http.Response response) async {
  if (response.statusCode == 401) {
    final appController = Get.find<AppController>();

    await appController.clearToken();

    Get.offAllNamed('/loginpage');

    Get.snackbar("Session Expired", "Please login again");
  }

  return response;
}
