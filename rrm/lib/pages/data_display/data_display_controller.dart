import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrm/controller.dart';
import 'package:rrm/services/tagging_service.dart';
import 'package:rrm/services/retagging_service.dart';
import 'package:rrm/services/claim_service.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';

class DatadisplayController extends GetxController {
  final AppController appController = Get.find();
  final TaggingService _taggingService = TaggingService();
  final RetaggingService _retaggingService = RetaggingService();
  final ClaimService _claimService = ClaimService();

  String? dataType; // "taggingdata", "retaggingdata", "claimdata"
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController searchcontroller = TextEditingController();

  bool isLoading = false;
  bool isSearching = false;
  List<dynamic> completedLeads = [];
  List<dynamic> filteredLeads = [];

  String get pageTitle {
    switch (dataType) {
      case "claimdata":
        return "Claim Data";
      case "retaggingdata":
        return "Retagging Data";
      default:
        return "Tagging Data";
    }
  }

  String get searchHint {
    switch (dataType) {
      case "claimdata":
        return "Search Claim Data";
      case "retaggingdata":
        return "Search Retagging Data";
      default:
        return "Search Tagging Data";
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == "claimdata") {
      dataType = "claimdata";
    } else if (args == "retaggingdata") {
      dataType = "retaggingdata";
    } else {
      dataType = "taggingdata";
    }
    fetchCompletedLeads();
  }

  // Future<void> fetchCompletedLeads() async {
  //   if (isLoading) return;

  //   final String token = appController.token.value;
  //   if (token.isEmpty) {
  //     showSnackBar("Session expired. Please log in again.", SNACK.FAILED);
  //     return;
  //   }

  //   try {
  //     isLoading = true;
  //     update();

  //     late final http.Response response;
  //     switch (dataType) {
  //       case "claimdata":
  //         response = await _claimService.completed(token: token);
  //         break;
  //       case "retaggingdata":
  //         response = await _retaggingService.completed(token: token);
  //         break;
  //       default:
  //         response = await _taggingService.completed(token: token);
  //     }

  //     debugPrint("$dataType completed response: "
  //         "status=${response.statusCode}, body=${response.body}");

  //     final decoded = jsonDecode(response.body);
  //     final bool isOk = response.statusCode >= 200 && response.statusCode < 300;

  //     if (isOk && decoded["status"] == "success") {
  //       final data = decoded["data"];
  //       // API may return data under different keys
  //       completedLeads = data is List
  //           ? data
  //           : (data?["taggings"] ?? data?["retaggings"] ?? data?["claims"] ?? data?["leads"] ?? []);
  //       filteredLeads = List.from(completedLeads);
  //     } else {
  //       final msg = decoded["message"] ?? "Failed to fetch data";
  //       if (response.statusCode == 401) {
  //         appController.clearToken();
  //         showSnackBar("Session expired. Please log in again.", SNACK.FAILED);
  //       } else {
  //         showSnackBar(msg, SNACK.FAILED);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Fetch completed leads error: $e");
  //     showSnackBar("Unable to fetch data. Check connection and retry.", SNACK.FAILED);
  //   } finally {
  //     isLoading = false;
  //     update();
  //   }
  // }

  Future<void> fetchCompletedLeads() async {
    if (isLoading) return;

    final String token = appController.token.value;
    if (token.isEmpty) {
      showSnackBar("Session expired. Please log in again.", SNACK.FAILED);
      return;
    }

    try {
      isLoading = true;
      update();

      late final http.Response response;

      switch (dataType) {
        case "claimdata":
          response = await _claimService.completed(token: token);
          break;

        case "retaggingdata":
          response = await _retaggingService.completed(token: token);
          break;

        default:
          response = await _taggingService.completed(token: token);
      }

      debugPrint(
        "$dataType completed response: "
        "status=${response.statusCode}, body=${response.body}",
      );

      final decoded = jsonDecode(response.body);

      final bool isOk = response.statusCode >= 200 && response.statusCode < 300;

      if (isOk && decoded["status"] == "success") {
        final data = decoded["data"];

        completedLeads = data is List
            ? data
            : (data?["results"] ??
                  data?["taggings"] ??
                  data?["retaggings"] ??
                  data?["claims"] ??
                  data?["leads"] ??
                  []);

        filteredLeads = List<Map<String, dynamic>>.from(completedLeads);

        debugPrint("completedLeads count = ${completedLeads.length}");

        debugPrint(
          "First Lead = ${completedLeads.isNotEmpty ? completedLeads.first : 'EMPTY'}",
        );
      } else {
        final msg = decoded["message"] ?? "Failed to fetch data";

        if (response.statusCode == 401) {
          appController.clearToken();
          showSnackBar("Session expired. Please log in again.", SNACK.FAILED);
        } else {
          showSnackBar(msg, SNACK.FAILED);
        }
      }
    } catch (e) {
      debugPrint("Fetch completed leads error: $e");

      showSnackBar(
        "Unable to fetch data. Check connection and retry.",
        SNACK.FAILED,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // Future<void> searchLeads(String searchString) async {
  //   if (searchString.trim().isEmpty) {
  //     filteredLeads = List.from(completedLeads);
  //     update();
  //     return;
  //   }

  //   final String token = appController.token.value;
  //   if (token.isEmpty) return;

  //   try {
  //     isSearching = true;
  //     update();

  //     late final http.Response response;
  //     switch (dataType) {
  //       case "claimdata":
  //         response = await _claimService.searchCompleted(
  //             token: token, searchString: searchString.trim());
  //         break;
  //       case "retaggingdata":
  //         response = await _retaggingService.searchCompleted(
  //             token: token, searchString: searchString.trim());
  //         break;
  //       default:
  //         response = await _taggingService.searchCompleted(
  //             token: token, searchString: searchString.trim());
  //     }

  //     final decoded = jsonDecode(response.body);
  //     final bool isOk = response.statusCode >= 200 && response.statusCode < 300;

  //     if (isOk && decoded["status"] == "success") {
  //       final data = decoded["data"];
  //       filteredLeads = data is List
  //           ? data
  //           : (data?["taggings"] ?? data?["retaggings"] ?? data?["claims"] ?? data?["leads"] ?? []);
  //     } else {
  //       showSnackBar(decoded["message"] ?? "Search failed", SNACK.FAILED);
  //     }
  //   } catch (e) {
  //     debugPrint("Search error: $e");
  //     showSnackBar("Search failed. Try again.", SNACK.FAILED);
  //   } finally {
  //     isSearching = false;
  //     update();
  //   }
  // }

  Future<void> searchLeads(String searchString) async {
    if (searchString.trim().isEmpty) {
      filteredLeads = List.from(completedLeads);
      update();
      return;
    }

    final String token = appController.token.value;

    if (token.isEmpty) return;

    try {
      isSearching = true;
      update();

      late final http.Response response;

      switch (dataType) {
        case "claimdata":
          response = await _claimService.searchCompleted(
            token: token,
            searchString: searchString.trim(),
          );
          break;

        case "retaggingdata":
          response = await _retaggingService.searchCompleted(
            token: token,
            searchString: searchString.trim(),
          );
          break;

        default:
          response = await _taggingService.searchCompleted(
            token: token,
            searchString: searchString.trim(),
          );
      }

      final decoded = jsonDecode(response.body);

      final bool isOk = response.statusCode >= 200 && response.statusCode < 300;

      if (isOk && decoded["status"] == "success") {
        final data = decoded["data"];

        filteredLeads = data is List
            ? data
            : (data?["results"] ??
                  data?["taggings"] ??
                  data?["retaggings"] ??
                  data?["claims"] ??
                  data?["leads"] ??
                  []);

        debugPrint("Search Results Count = ${filteredLeads.length}");
      } else {
        showSnackBar(decoded["message"] ?? "Search failed", SNACK.FAILED);
      }
    } catch (e) {
      debugPrint("Search error: $e");

      showSnackBar("Search failed. Try again.", SNACK.FAILED);
    } finally {
      isSearching = false;
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

      late final http.Response response;
      switch (dataType) {
        case "claimdata":
          response = await _claimService.getById(token: token, id: id);
          break;
        case "retaggingdata":
          response = await _retaggingService.getById(token: token, id: id);
          break;
        default:
          response = await _taggingService.getTagging(token: token, id: id);
      }

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

  Future<void> downloadCertificate(String id) async {
    final String token = appController.token.value;
    if (token.isEmpty) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      late final http.Response response;
      switch (dataType) {
        case "claimdata":
          response = await _claimService.downloadCertificate(
            token: token,
            id: id,
          );
          break;
        case "retaggingdata":
          response = await _retaggingService.downloadCertificate(
            token: token,
            id: id,
          );
          break;
        default:
          response = await _taggingService.downloadHealthCertificate(
            token: token,
            id: id,
          );
      }

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showSnackBar("Certificate downloaded successfully", SNACK.SUCCESS);
      } else {
        final decoded = jsonDecode(response.body);
        showSnackBar(decoded["message"] ?? "Download failed", SNACK.FAILED);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Download certificate error: $e");
      showSnackBar("Download failed. Try again.", SNACK.FAILED);
    }
  }

  Future<void> downloadAllCertificates() async {
    final String token = appController.token.value;
    if (token.isEmpty) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      late final http.Response response;
      switch (dataType) {
        case "claimdata":
          response = await _claimService.downloadAllCertificates(token: token);
          break;
        case "retaggingdata":
          response = await _retaggingService.downloadAllCertificates(
            token: token,
          );
          break;
        default:
          response = await _taggingService.downloadAllHealthCertificates(
            token: token,
          );
      }

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showSnackBar("All certificates downloaded successfully", SNACK.SUCCESS);
      } else {
        final decoded = jsonDecode(response.body);
        showSnackBar(decoded["message"] ?? "Download failed", SNACK.FAILED);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Download all certificates error: $e");
      showSnackBar("Download failed. Try again.", SNACK.FAILED);
    }
  }

  @override
  void onClose() {
    searchcontroller.dispose();
    super.onClose();
  }
}
