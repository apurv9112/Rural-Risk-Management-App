import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/tagging_service.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';

class TaggingController extends GetxController {
  final AppController appController = Get.find();

  final TaggingService _taggingService = TaggingService();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController loanaccoutnumbercontroller = TextEditingController();
  TextEditingController nameofcattleownercontroller = TextEditingController();
  TextEditingController villagecontroller = TextEditingController();
  TextEditingController talukacontroller = TextEditingController();
  TextEditingController distcontroller = TextEditingController();

  bool listshow = true;
  bool manualtagging = false;
  bool isLoading = false;

  List<dynamic> taggings = [];

  @override
  void onInit() {
    super.onInit();
    _fetchInitialData();
  }

  /// Fetch all assigned taggings when the screen first opens.
  Future<void> _fetchInitialData() async {
    final String token = appController.token.value;
    if (token.isEmpty) return;

    isLoading = true;
    update();

    try {
      final response = await _taggingService.listAssigned(token: token);
      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded["status"] == "success") {
        taggings = decoded["data"]?["leads"]?["tagging"] ?? decoded["data"]?["taggings"] ?? [];
        listshow = false;

        if (taggings.isNotEmpty) {
          final first = taggings[0];
          debugPrint("=== TAGGING API RESPONSE (first lead) ===");
          debugPrint("sumInsuredCow: ${first['sumInsuredCow']}");
          debugPrint("sumInsuredBuffalo: ${first['sumInsuredBuffalo']}");
          debugPrint("numberOfCow: ${first['numberOfCow']}");
          debugPrint("numberOfBuffalo: ${first['numberOfBuffalo']}");
          debugPrint("All keys: ${first.keys.toList()}");
          debugPrint("=========================================");
        }
      }
    } catch (e) {
      debugPrint("Initial tagging fetch error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> search() async {
    if (isLoading) return;

    try {
      final String token = appController.token.value;

      if (token.isEmpty) {
        showSnackBar(
          "Session expired. Please log in again.",
          SNACK.FAILED,
        );
        debugPrint("Tagging search blocked: missing token");
        return;
      }

      debugPrint("Tagging search token length: ${token.length}");

      isLoading = true;
      update();

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final Map<String, dynamic> payload = {
        "page": 1,
        "limit": 10,
        "mobileNo": mobilecontroller.text.trim(),
        "loanAccountNo": loanaccoutnumbercontroller.text.trim(),
        "ownerName": nameofcattleownercontroller.text.trim(),
        "village": villagecontroller.text.trim(),
        "taluko": talukacontroller.text.trim(),
        "district": distcontroller.text.trim(),
      };

      payload.removeWhere(
        (_, value) => value is String && value.isEmpty,
      );

      final response = await _taggingService.searchTagging(
        token: token,
        body: payload,
      );

      debugPrint(
        "Tagging search response: status=${response.statusCode}, body=${response.body}",
      );

      final decoded = jsonDecode(response.body);

      final bool isOkStatus = response.statusCode >= 200 && response.statusCode < 300;
      if (isOkStatus && decoded["status"] == "success") {
        taggings = decoded["data"]["taggings"] ?? [];
        listshow = false;

        if (taggings.isNotEmpty) {
          final first = taggings[0];
          debugPrint("=== TAGGING SEARCH RESPONSE (first lead) ===");
          debugPrint("sumInsuredCow: ${first['sumInsuredCow']}");
          debugPrint("sumInsuredBuffalo: ${first['sumInsuredBuffalo']}");
          debugPrint("numberOfCow: ${first['numberOfCow']}");
          debugPrint("numberOfBuffalo: ${first['numberOfBuffalo']}");
          debugPrint("All keys: ${first.keys.toList()}");
          debugPrint("=============================================");
        }
      } else {
        final msg = decoded["message"] ?? "Search failed";
        if (response.statusCode == 401) {
          appController.clearToken();
          showSnackBar("Session expired. Please log in again.", SNACK.FAILED);
        } else {
          showSnackBar(msg, SNACK.FAILED);
        }
        return;
      }
    } catch (e) {
      debugPrint("Tagging search error: $e");
      if (!(Get.isDialogOpen ?? false)) {
        showSnackBar("Unable to search right now. Check connection and retry.", SNACK.FAILED);
      }
    } finally {
      isLoading = false;
      if (Get.isDialogOpen ?? false) Get.back();
      update();
    }
  }

  @override
  void onClose() {
    mobilecontroller.dispose();
    loanaccoutnumbercontroller.dispose();
    nameofcattleownercontroller.dispose();
    villagecontroller.dispose();
    talukacontroller.dispose();
    distcontroller.dispose();
    super.onClose();
  }
}
