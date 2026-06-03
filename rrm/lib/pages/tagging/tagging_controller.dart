import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/services/tagging_service.dart';

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
  ScrollController scrollController = ScrollController();

  bool listshow = true;
  bool manualtagging = false;
  bool isLoading = false;
  int currentPage = 1;
  bool hasMoreData = true;
  bool isPaginationLoading = false;
  List<dynamic> taggings = [];

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();

    scrollController.addListener(() {
      debugPrint("SCROLL: ${scrollController.position.pixels}");
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isPaginationLoading &&
          hasMoreData) {
        debugPrint("BOTTOM REACHED");
        loadMoreData();
      }
    });
  }

  bool isSearching = false;

  bool hasSearchValue() {
    return mobilecontroller.text.trim().isNotEmpty ||
        loanaccoutnumbercontroller.text.trim().isNotEmpty ||
        nameofcattleownercontroller.text.trim().isNotEmpty ||
        villagecontroller.text.trim().isNotEmpty ||
        talukacontroller.text.trim().isNotEmpty ||
        distcontroller.text.trim().isNotEmpty;
  }

  /// Fetch all assigned taggings when the screen first opens.
  // Future<void> fetchInitialData() async {
  //   final String token = appController.token.value;
  //   if (token.isEmpty) return;

  //   isLoading = true;
  //   update();

  //   try {
  //     final response = await _taggingService.listAssigned(token: token);

  //     final decoded = jsonDecode(response.body);

  //     if (response.statusCode >= 200 &&
  //         response.statusCode < 300 &&
  //         decoded["status"] == "success") {
  //       taggings =
  //           decoded["data"]?["leads"]?["tagging"] ??
  //           decoded["data"]?["taggings"] ??
  //           [];
  //       listshow = false; // Add this line

  //       if (taggings.isNotEmpty) {
  //         final first = taggings[0];
  //         debugPrint("=== TAGGING API RESPONSE (first lead) ===");
  //         debugPrint("sumInsuredCow: ${first['sumInsuredCow']}");
  //         debugPrint("sumInsuredBuffalo: ${first['sumInsuredBuffalo']}");
  //         debugPrint("numberOfCow: ${first['numberOfCow']}");
  //         debugPrint("numberOfBuffalo: ${first['numberOfBuffalo']}");
  //         debugPrint("All keys: ${first.keys.toList()}");
  //         debugPrint("=========================================");
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Initial tagging fetch error: $e");
  //   } finally {
  //     isLoading = false;
  //     update();
  //   }
  // }

  Future<void> fetchInitialData() async {
    final String token = appController.token.value;
    if (token.isEmpty) return;

    isLoading = true;
    isSearching = false;
    update();

    try {
      final response = await _taggingService.listAssigned(token: token);

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded["status"] == "success") {
        taggings =
            decoded["data"]?["leads"]?["tagging"] ??
            decoded["data"]?["taggings"] ??
            [];

        listshow = false;
        hasMoreData = false;
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

      isLoading = true;

      currentPage = 1;
      hasMoreData = true;

      update();

      final Map<String, dynamic> payload = {
        "page": currentPage,
        "limit": 20,
        "mobileNo": mobilecontroller.text.trim(),
        "loanAccountNo": loanaccoutnumbercontroller.text.trim(),
        "ownerName": nameofcattleownercontroller.text.trim(),
        "village": villagecontroller.text.trim(),
        "taluko": talukacontroller.text.trim(),
        "district": distcontroller.text.trim(),
      };

      payload.removeWhere((_, value) => value is String && value.isEmpty);

      final response = await _taggingService.searchTagging(
        token: token,
        body: payload,
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded["status"] == "success") {
        taggings = decoded["data"]["taggings"] ?? [];

        /// if less than limit => no more data
        if (taggings.length < 20) {
          hasMoreData = false;
        }

        listshow = false;
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> loadMoreData() async {
    if (!hasMoreData || isPaginationLoading) return;

    try {
      isPaginationLoading = true;
      update();

      currentPage++;

      final String token = appController.token.value;

      final Map<String, dynamic> payload = {
        "page": currentPage,
        "limit": 20,
        "mobileNo": mobilecontroller.text.trim(),
        "loanAccountNo": loanaccoutnumbercontroller.text.trim(),
        "ownerName": nameofcattleownercontroller.text.trim(),
        "village": villagecontroller.text.trim(),
        "taluko": talukacontroller.text.trim(),
        "district": distcontroller.text.trim(),
      };

      payload.removeWhere((_, value) => value is String && value.isEmpty);

      final response = await _taggingService.searchTagging(
        token: token,
        body: payload,
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded["status"] == "success") {
        List<dynamic> newData = decoded["data"]["taggings"] ?? [];

        if (newData.isEmpty) {
          hasMoreData = false;
        } else {
          taggings.addAll(newData);

          if (newData.length < 20) {
            hasMoreData = false;
          }
        }
      }
    } catch (e) {
      debugPrint("Pagination Error: $e");
    } finally {
      isPaginationLoading = false;
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
