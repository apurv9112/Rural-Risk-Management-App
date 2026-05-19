import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:rrm/pages/home/drawer.dart';
import 'package:rrm/pages/home/home_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

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
                            Get.back();
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
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          key: controller.scaffoldKey,
          backgroundColor: AppColors.PRIMARY_COLOR,

          appBar: CustomAppBarAction(
            title: 'Dashboard',

            iconleft: Icons.menu,
            lefticononTap: () {
              controller.scaffoldKey.currentState!.openDrawer();
            },

            /// PROFILE ICON
            iconright: Icons.perm_identity_outlined,
            righticononTap: () {
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(wp(4)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Profile",
                                style: TextStyle(
                                  fontSize: dp(context, 22),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.PRIMARY_COLOR,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),

                          SizedBox(height: hp(1)),

                          /// USER DETAILS
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(wp(4)),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildDetailRow(
                                  title: "Name",
                                  value:
                                      controller.appController.userName.value,

                                  context: context,
                                ),

                                SizedBox(height: hp(1)),

                                buildDetailRow(
                                  title: "Mobile",
                                  value: controller
                                      .appController
                                      .mobileNumber
                                      .value,
                                  context: context,
                                ),

                                SizedBox(height: hp(1)),

                                buildDetailRow(
                                  title: "Email",
                                  value: controller.appController.email.value,
                                  context: context,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: hp(2)),

                          /// SIGNATURE TITLE
                          Text(
                            "Signature",
                            style: TextStyle(
                              fontSize: dp(context, 18),
                              fontWeight: FontWeight.w600,
                              color: AppColors.PRIMARY_COLOR,
                            ),
                          ),

                          SizedBox(height: hp(1.5)),

                          /// SIGNATURE PREVIEW
                          Container(
                            height: hp(22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.DARK),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: GestureDetector(
                                onTap: () async {
                                  await openLandscapeSignature(
                                    context: context,
                                    controller: controller.signatureController,
                                  );
                                },
                                child: ValueListenableBuilder(
                                  valueListenable:
                                      controller.signatureController,
                                  builder: (context, value, child) {
                                    return FutureBuilder<Uint8List?>(
                                      future:
                                          controller
                                              .signatureController
                                              .isNotEmpty
                                          ? controller.signatureController
                                                .toPngBytes()
                                          : Future.value(null),
                                      builder: (context, snapshot) {
                                        /// SAVED SIGNATURE
                                        if (controller
                                                .signaturePath
                                                .value
                                                .isNotEmpty &&
                                            File(
                                              controller.signaturePath.value,
                                            ).existsSync()) {
                                          return Image.file(
                                            File(
                                              controller.signaturePath.value,
                                            ),
                                            fit: BoxFit.cover,
                                          );
                                        }

                                        /// CURRENT DRAW SIGNATURE
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          );
                                        }

                                        return const Center(
                                          child: Text(
                                            "Tap to Sign",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: hp(2)),

                          /// BUTTONS
                          Row(
                            children: [
                              /// CAMERA
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await controller.pickSignatureImage(
                                      source: ImageSource.camera,
                                    );
                                  },

                                  icon: Icon(Icons.camera_alt),

                                  label: Text("Camera"),
                                ),
                              ),

                              SizedBox(width: wp(3)),

                              /// GALLERY
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await controller.pickSignatureImage(
                                      source: ImageSource.gallery,
                                    );
                                  },

                                  icon: Icon(Icons.photo),

                                  label: Text("Gallery"),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: hp(2)),
                          Row(
                            children: [
                              /// CLEAR
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    // controller.signatureController.clear();
                                    await controller.clearSignature();
                                  },
                                  icon: Icon(
                                    Icons.refresh,
                                    color: AppColors.WHITE,
                                  ),
                                  label: Text(
                                    "Clear",
                                    style: TextStyle(color: AppColors.WHITE),
                                  ),
                                ),
                              ),

                              SizedBox(width: wp(3)),

                              /// SAVE
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.PRIMARY_COLOR,
                                  ),
                                  onPressed: () async {
                                    await controller.saveSignature();

                                    controller.update();
                                  },
                                  icon: Icon(
                                    Icons.save,
                                    color: AppColors.WHITE,
                                  ),
                                  label: Text(
                                    "Save",
                                    style: TextStyle(color: AppColors.WHITE),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          drawer: customdrawer(context: context),

          body: Column(
            children: [
              SizedBox(height: hp(12)),

              customcontainer(
                onTap: () {
                  Get.toNamed(routetaggingpage);
                },
                context: context,
                logo: 'assets/images/home_logo_1.png',
                rowwidth: wp(10),
                name: "CATTLE \nTAGGING",
              ),

              SizedBox(height: hp(3)),

              customcontainer(
                onTap: () {
                  Get.toNamed(routeclaimpage);
                },
                logo: 'assets/images/home_logo_2.png',
                rowwidth: wp(15),
                name: 'CATTLE \nCLAIM',
                context: context,
              ),

              SizedBox(height: hp(3)),

              customcontainer(
                onTap: () {
                  Get.toNamed(
                    routeclaimpage,
                    arguments: {"retagging": controller.retagging},
                  );
                },
                logo: 'assets/images/home_logo_3.png',
                rowwidth: wp(7),
                name: "CATTLE \nRETAGGING",
                context: context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDetailRow({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontSize: dp(context, 15),
              fontWeight: FontWeight.w600,
              color: AppColors.PRIMARY_COLOR,
            ),
          ),
        ),

        Expanded(
          flex: 4,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: dp(context, 15), color: AppColors.DARK),
          ),
        ),
      ],
    );
  }
}

customcontainer({
  required String logo,
  required String name,
  required BuildContext context,
  required double? rowwidth,
  required void Function()? onTap,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  double? fontSize,
  double? imgheight,
  double? imgwidth,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dp(context, 15)),
        border: Border.all(color: AppColors.DARK),
        color: AppColors.WHITE,
      ),
      padding: padding ?? EdgeInsets.symmetric(horizontal: wp(5)),
      margin: margin ?? EdgeInsets.symmetric(horizontal: wp(6)),
      child: Row(
        children: [
          Image.asset(
            logo,
            height: imgheight ?? hp(15),
            width: imgwidth ?? wp(20),
          ),

          SizedBox(width: rowwidth),

          Text(
            name,
            style: TextStyle(
              fontSize: fontSize ?? dp(context, 30),
              color: AppColors.PRIMARY_COLOR,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
