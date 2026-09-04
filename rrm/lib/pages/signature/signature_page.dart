// signature_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:signature/signature.dart';
import 'signature_controller.dart';

class SignaturePage extends StatelessWidget {
  SignaturePage({super.key});

  final controller = Get.find<SignatureControllerX>();

  Future<void> openLandscapeSignature({
    required BuildContext context,
    required SignatureController controller,
  }) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await Get.dialog(
      Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Draw Signature",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            controller.clear();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Clear"),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("OK"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Signature(
                    controller: controller,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};

    final String tagNo = args["tagNo"]?.toString() ?? "";

    final String leadId = args["leadId"]?.toString() ?? "";

    final String leadType = args["leadType"]?.toString() ?? "";

    final String folderId = args["folderId"]?.toString() ?? "";

    final String ownerName = args["customerName"] ?? "";

    print(
      "leadId:$leadId, leadType:$leadType, folderId:$folderId, ownerName:$ownerName",
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.PRIMARY_COLOR,
        appBar: CustomAppBarAction(
          title: "SIGNATURE",
          iconleft: Icons.arrow_back_outlined,
          // lefticononTap: () {
          //   Get.back();
          // },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: controller.formKey,
              child: Padding(
                padding: EdgeInsets.only(top: hp(4), right: wp(4), left: wp(4)),
                child: Column(
                  children: [
                    /// CUSTOMER DETAILS
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: wp(5),
                        vertical: hp(1),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(dp(context, 15)),
                        border: Border.all(color: AppColors.DARK),
                        color: AppColors.WHITE,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: AppColors.PRIMARY_COLOR,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Customer Details",
                                style: TextStyle(
                                  fontSize: dp(context, 20),
                                  color: AppColors.PRIMARY_COLOR,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: hp(2)),

                          buildDetailRow("Owner Name", ownerName, context),
                        ],
                      ),
                    ),

                    SizedBox(height: hp(2)),

                    /// CUSTOMER SIGNATURE
                    buildSignatureCard(
                      context: context,
                      title: "1. Customer Signature",
                      subtitle:
                          "I hereby declare that the information given above is true and correct to the best of my knowledge and belief.",
                      signatureController:
                          controller.customerSignatureController,
                      onClear: () {
                        controller.customerSignatureController.clear();
                      },
                    ),

                    SizedBox(height: hp(2)),

                    /// WORKER SIGNATURE
                    buildWorkerSignatureCard(
                      context: context,
                      controller: controller,
                    ),

                    SizedBox(height: hp(2)),

                    /// SAVE BUTTON
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.WHITE,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: controller.isSaving.value
                              ? null
                              : () {
                                  controller.saveSignatures(
                                    tagNo: tagNo,
                                    leadId: leadId,
                                    leadType: leadType,
                                    folderId: folderId,
                                  );
                                },
                          icon: controller.isSaving.value
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.PRIMARY_COLOR,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.save,
                                  color: AppColors.PRIMARY_COLOR,
                                ),
                          label: Text(
                            controller.isSaving.value ? "Saving..." : "Save",
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.PRIMARY_COLOR,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: hp(2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontSize: dp(context, 16),
                color: AppColors.PRIMARY_COLOR,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: dp(context, 16),
                color: AppColors.DARK,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSignatureCard({
    required String title,
    required String subtitle,
    required SignatureController signatureController,
    required VoidCallback onClear,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: dp(context, 16),
                    color: AppColors.PRIMARY_COLOR,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh, color: Colors.green),
                label: const Text(
                  "Clear",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),

          SizedBox(height: hp(1)),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: dp(context, 12),
              color: AppColors.DARK.shade500,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: hp(2)),

          Container(
            height: hp(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(dp(context, 15)),
              border: Border.all(color: AppColors.DARK),
              color: AppColors.WHITE,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: () async {
                  await openLandscapeSignature(
                    context: context,
                    controller: signatureController,
                  );
                },
                child: ValueListenableBuilder(
                  valueListenable: signatureController,
                  builder: (context, value, child) {
                    return FutureBuilder<Uint8List?>(
                      future: signatureController.isNotEmpty
                          ? signatureController.toPngBytes()
                          : Future.value(null),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: const EdgeInsets.all(12),
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            ),
                          );
                        }

                        return const Center(
                          child: Text(
                            "Tap to Sign",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWorkerSignatureCard({
    required BuildContext context,
    required SignatureControllerX controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Obx(() {
        final File? file = controller.workerSignatureFile.value;

        /// ===============================
        /// NO SIGNATURE
        /// ===============================
        if (file == null || !file.existsSync()) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "2. Field Worker Signature",
                style: TextStyle(
                  fontSize: dp(context, 16),
                  color: AppColors.PRIMARY_COLOR,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: hp(1)),

              const Text(
                "No profile signature found.\n"
                "This signature will be saved and reused for future Tagging, Retagging and Claim.",
              ),

              SizedBox(height: hp(3)),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.draw),
                  label: const Text("Draw Signature"),
                  onPressed: () async {
                    await openLandscapeSignature(
                      context: context,
                      controller: controller.workerSignatureController,
                    );

                    await controller.saveWorkerSignatureFromCanvas();
                  },
                ),
              ),

              SizedBox(height: hp(1.5)),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Upload From Gallery"),
                  onPressed: () {
                    controller.pickWorkerSignature(source: ImageSource.gallery);
                  },
                ),
              ),
            ],
          );
        }

        /// ===============================
        /// SIGNATURE AVAILABLE
        /// ===============================
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "2. Field Worker Signature",
              style: TextStyle(
                fontSize: dp(context, 16),
                color: AppColors.PRIMARY_COLOR,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: hp(2)),

            Container(
              height: hp(30),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: Image.file(file, fit: BoxFit.contain),
            ),

            SizedBox(height: hp(2)),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Draw Again"),
                    onPressed: () async {
                      await openLandscapeSignature(
                        context: context,
                        controller: controller.workerSignatureController,
                      );

                      await controller.saveWorkerSignatureFromCanvas();
                    },
                  ),
                ),

                SizedBox(width: wp(2)),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                    onPressed: () {
                      controller.pickWorkerSignature(
                        source: ImageSource.gallery,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
