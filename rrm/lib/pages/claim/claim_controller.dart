import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/claim_service.dart';
import 'package:rrm/services/retagging_service.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';

class ClaimController extends GetxController {
  final AppController appController = Get.find();
  final ClaimService _claimService = ClaimService();
  final RetaggingService _retaggingService = RetaggingService();

  String? claim = "claim";
  String? retagging;
  bool isLoading = false;
  List<dynamic> leads = [];

  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilenumbercontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController villegcontroller = TextEditingController();
  TextEditingController talukcontroller = TextEditingController();
  TextEditingController districcontroller = TextEditingController();
  TextEditingController buffalocountcontroller = TextEditingController();

  bool get isRetagging => retagging != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    retagging = args != null ? args["retagging"] : null;
    fetchLeads();
  }

  Future<void> fetchLeads() async {
    if (isLoading) return;

    final String token = appController.token.value;
    if (token.isEmpty) {
      showSnackBar("Session expired. Please log in again.", SNACK.FAILED);
      return;
    }

    try {
      isLoading = true;
      update();

      final response = isRetagging
          ? await _retaggingService.listAssigned(token: token)
          : await _claimService.listAssigned(token: token);

      debugPrint(
        "${isRetagging ? 'Retagging' : 'Claim'} leads response: "
        "status=${response.statusCode}, body=${response.body}",
      );

      final decoded = jsonDecode(response.body);
      final bool isOk = response.statusCode >= 200 && response.statusCode < 300;

      if (isOk && decoded["status"] == "success") {
        if (isRetagging) {
          leads = decoded["data"]?["leads"]?["retagging"] ?? [];
        } else {
          leads = decoded["data"]?["leads"]?["claim"] ?? [];
        }
      } else {
        final msg = decoded["message"] ?? "Failed to fetch leads";
        if (response.statusCode == 401) {
          appController.clearToken();
          showSnackBar("Session expired. Please log in again.", SNACK.FAILED);
        } else {
          showSnackBar(msg, SNACK.FAILED);
        }
      }
    } catch (e) {
      debugPrint("Fetch leads error: $e");
      showSnackBar(
        "Unable to fetch leads. Check connection and retry.",
        SNACK.FAILED,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<Map<String, dynamic>?> getLeadDetails(String id) async {
    final String token = appController.token.value;
    if (token.isEmpty) return null;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = isRetagging
          ? await _retaggingService.getById(token: token, id: id)
          : await _claimService.getById(token: token, id: id);

      if (Get.isDialogOpen ?? false) Get.back();

      final decoded = jsonDecode(response.body);
      final bool isOk = response.statusCode >= 200 && response.statusCode < 300;

      if (isOk && decoded["status"] == "success") {
        return decoded["data"] as Map<String, dynamic>?;
      } else {
        showSnackBar(
          decoded["message"] ?? "Failed to get details",
          SNACK.FAILED,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Get lead detail error: $e");
      showSnackBar("Unable to get details. Try again.", SNACK.FAILED);
    }
    return null;
  }

  @override
  void onClose() {
    namecontroller.dispose();
    mobilenumbercontroller.dispose();
    addresscontroller.dispose();
    villegcontroller.dispose();
    talukcontroller.dispose();
    districcontroller.dispose();
    buffalocountcontroller.dispose();
    super.onClose();
  }
}
