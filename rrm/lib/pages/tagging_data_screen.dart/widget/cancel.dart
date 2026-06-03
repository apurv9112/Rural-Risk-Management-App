import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:rrm/pages/tagging_data_screen.dart/tagging_data_controller.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/custom_camera_button.dart';
import 'package:rrm/widgets/customcontainer.dart';

void showDialogWithFields({
  required BuildContext context,
  required TaggingdataController controller,
  Widget? title,
  Widget? content,
  List<Widget>? actions,
}) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        titleTextStyle: TextStyle(
          color: Colors.red,
          fontSize: dp(context, 20),
          fontStyle: FontStyle.italic,
        ),
        title:
            title ??
            Text(
              controller.ischangepage == null
                  ? "Lead Cancel"
                  : controller.retagging != null
                  ? "RT Cancel"
                  : "Claim Cancel",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.PRIMARY_COLOR,
                fontWeight: FontWeight.w500,
              ),
            ),
        content:
            content ??
            SizedBox(
              height: hp(30),
              width: wp(70),
              child: GetBuilder<TaggingdataController>(
                id: 'cancelDialog',
                builder: (controller) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: controller.selectedReasonDropdown,
                        decoration: InputDecoration(
                          hintText: "Select Reason",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        items:
                            (controller.ischangepage == null
                                    ? controller.taggingreasons
                                    : controller.retagging != null
                                    ? controller.retaggingreasons
                                    : controller.claimreasons)
                                .map((reason) {
                                  return DropdownMenuItem<String>(
                                    value: reason,
                                    child: Text(reason),
                                  );
                                })
                                .toList(),
                        onChanged: (value) {
                          controller.selectedReasonDropdown = value;
                          // controller.update(['cancelDialog']);
                        },
                      ),
                      SizedBox(height: hp(1)),
                      Padding(
                        padding: EdgeInsets.only(left: wp(7)),
                        child: Text(
                          "Add Photo :",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.PRIMARY_COLOR,
                            fontSize: dp(context, 14),
                          ),
                        ),
                      ),

                      SizedBox(height: hp(1.5)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              custombuttomsheet(
                                context: context,
                                controller: controller,
                                isimage: 1,
                              );
                            },
                            child: Container(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: wp(1),
                                vertical: hp(0.5),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.PRIMARY_COLOR,
                                  width: wp(0.5),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: controller.selectedOther1.value == null
                                  ? Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppColors.PRIMARY_COLOR,
                                      size: dp(context, 45),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        dp(context, 8),
                                      ),
                                      child: Image.file(
                                        controller.selectedOther1.value!,
                                        fit: BoxFit.fill,
                                        height: hp(6),
                                        width: wp(13),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: wp(2.5)),
                          GestureDetector(
                            onTap: () {
                              custombuttomsheet(
                                context: context,
                                controller: controller,
                                isimage: 2,
                              );
                            },
                            child: Container(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: wp(1),
                                vertical: hp(0.5),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.PRIMARY_COLOR,
                                  width: wp(0.5),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: controller.selectedOther2.value == null
                                  ? Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppColors.PRIMARY_COLOR,
                                      size: dp(context, 45),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        dp(context, 8),
                                      ),
                                      child: Image.file(
                                        controller.selectedOther2.value!,
                                        fit: BoxFit.fill,
                                        height: hp(6),
                                        width: wp(13),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: wp(2.5)),
                          GestureDetector(
                            onTap: () {
                              custombuttomsheet(
                                context: context,
                                controller: controller,
                                isimage: 3,
                              );
                            },
                            child: Container(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: wp(1),
                                vertical: hp(0.5),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.PRIMARY_COLOR,
                                  width: wp(0.5),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: controller.selectedOther3.value == null
                                  ? Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppColors.PRIMARY_COLOR,
                                      size: dp(context, 45),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        dp(context, 8),
                                      ),
                                      child: Image.file(
                                        controller.selectedOther3.value!,
                                        fit: BoxFit.fill,
                                        height: hp(6),
                                        width: wp(13),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
        contentTextStyle: TextStyle(
          fontSize: dp(context, 15),
          color: AppColors.DARK,
        ),
        actions:
            actions ??
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Customcontainer(
                    onTap: () async {
                      print("YES BUTTON CLICKED");

                      if (controller.selectedReasonDropdown == null) {
                        Get.snackbar("Error", "Please select reason");
                        return;
                      }

                      Get.back();

                      print("CALLING API...");

                      await controller.cancelLeadUniversal();

                      if (Get.isDialogOpen ?? false) Get.back();
                    },
                    context: context,
                    width: wp(32),
                    text: "Yes",
                    textcolor: AppColors.WHITE,
                    color: Colors.red,
                  ),
                  SizedBox(width: wp(2)),
                  Customcontainer(
                    onTap: () {
                      Get.back();
                    },
                    width: wp(32),
                    context: context,
                    text: "No",
                    textcolor: AppColors.WHITE,
                    color: AppColors.PRIMARY_COLOR,
                  ),
                ],
              ),
            ],
      );
    },
  );
}
