import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/device_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/services/auth_service.dart';
import 'package:rrm/widgets/snackbar_widget.dart';

class LoginController extends GetxController {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController mobilecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DeviceController deviceController = Get.find();
  final AppController appController = Get.find();
  final AuthService _authService = AuthService();

  bool isemail = true;

  Future<void> submitLogin() async {
    if (!formKey.currentState!.validate()) return;

    if (deviceController.deviceId.value.isEmpty) {
      await deviceController.fetchDeviceId();
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final payload = isemail
          ? {
              "mobileNo": mobilecontroller.text.trim(),
              "password": passwordcontroller.text.trim(),
              "deviceId": deviceController.deviceId.value,
            }
          : {
              "email": emailcontroller.text.trim(),
              "password": passwordcontroller.text.trim(),
              "deviceId": deviceController.deviceId.value,
            };

      debugPrint("Login payload keys: ${payload.keys}");

      final resp = await _authService.login(payload);

      debugPrint(
        "Login response: status=${resp.statusCode}, body=${resp.body}",
      );

      if (Get.isDialogOpen ?? false) Get.back();

      final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};

      if (resp.statusCode == 200 && decoded["status"] == "success") {
        final String token = _extractToken(decoded, resp.headers);

        if (token.isEmpty) {
          showSnackBar(
            "Login succeeded but no session token returned.",
            SNACK.FAILED,
          );
          debugPrint("Login missing token. Body keys: ${decoded.keys}");
          return;
        }

        appController.setToken(token);
        debugPrint("Login token saved (${token.length} chars)");

        /// USER DATA
        final userData = decoded["data"]["user"];

        appController.setUserData(
          name: "${userData["firstName"] ?? ""} ${userData["lastName"] ?? ""}",
          mobile: userData["mobileNo"] ?? "",
          email: userData["email"] ?? "",
        );

        debugPrint("USER NAME ::: ${appController.userName.value}");

        showSnackBar(decoded["message"] ?? "Login successful", SNACK.SUCCESS);
        Get.offAllNamed(routehomepage);
      } else {
        showSnackBar(decoded["message"] ?? "Login failed", SNACK.FAILED);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      showSnackBar("Network error. Please try again.", SNACK.FAILED);
    }
  }

  // ✅ GetX-safe dialog (NO BuildContext)
  void showDeviceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("RRM ID"),
        content: Text(deviceController.deviceId.value),
        actions: [TextButton(onPressed: Get.back, child: const Text("OK"))],
      ),
    );
  }

  @override
  void onClose() {
    emailcontroller.dispose();
    mobilecontroller.dispose();
    passwordcontroller.dispose();
    super.onClose();
  }

  String _extractToken(
    Map<String, dynamic> decoded,
    Map<String, String> headers,
  ) {
    dynamic readPath(Map<String, dynamic> map, List<String> path) {
      dynamic current = map;
      for (final key in path) {
        if (current is Map && current.containsKey(key)) {
          current = current[key];
        } else {
          return null;
        }
      }
      return current;
    }

    String? fromSetCookie(String? setCookie) {
      if (setCookie == null) return null;
      final parts = setCookie.split(';');
      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length == 2 && kv[0].toLowerCase().contains('token')) {
          return kv[1].trim();
        }
      }
      return null;
    }

    String? findTokenRecursively(dynamic node) {
      if (node is Map) {
        for (final entry in node.entries) {
          if (entry.value is String) {
            final key = entry.key.toString().toLowerCase();
            if (key.contains('token') || key.contains('auth')) {
              final val = (entry.value as String).trim();
              if (val.isNotEmpty) return val;
            }
          }
          final child = findTokenRecursively(entry.value);
          if (child != null) return child;
        }
      } else if (node is List) {
        for (final item in node) {
          final child = findTokenRecursively(item);
          if (child != null) return child;
        }
      }
      return null;
    }

    final candidates = <dynamic>[
      decoded["token"],
      decoded["accessToken"],
      decoded["access_token"],
      decoded["authToken"],
      decoded["authorization"],
      readPath(decoded, ["data", "token"]),
      readPath(decoded, ["data", "accessToken"]),
      readPath(decoded, ["data", "access_token"]),
      readPath(decoded, ["data", "authToken"]),
      readPath(decoded, ["data", "authorization"]),
      readPath(decoded, ["data", "access", "token"]),
      readPath(decoded, ["tokens", "access", "token"]),
      readPath(decoded, ["data", "tokens", "access", "token"]),
      headers["authorization"],
      headers["Authorization"],
      fromSetCookie(headers["set-cookie"]),
      findTokenRecursively(decoded),
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return '';
  }
}
