import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/pages/tagging_data_screen.dart/tagging_data_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/custom_camera_button.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/text_field.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class TaggingDataScreen extends StatelessWidget {
  const TaggingDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaggingdataController>(
      init: TaggingdataController(),
      builder: (controller) {
        final args = Get.arguments;
        print("args ;;;; $args");
        controller.retagging = args != null ? args["retagging"] : null;
        controller.data = args != null ? args["tagging"] : null;
        controller.ischangepage = args != null ? args["isclaim"] : null;
        controller.manualtagging = args != null ? args["manualtagging"] : null;
        controller.dateofdeathcontroller.text = DateFormat(
          'yyyy-MM-dd',
        ).format(controller.selectedDate.value!);

        controller.timeofdeathcontroller.text = controller.retagging != null
            ? "5504845226"
            : controller.selectedTime.value!.format(context);

        controller.namecontroller.text = controller.ischangepage == null
            ? controller.data.toString()
            : "Apuv Patel";
        controller.mobilenumbercontroller.text = "7572855882";
        controller.addresscontroller.text = "Plot no 30 Giriraj Greens";
        controller.villegcontroller.text = "Gabat";
        controller.talukcontroller.text = "Bayad";
        controller.districcontroller.text = "Aravalli";
        controller.banknamecontroller.text = "BOB";
        controller.branchcontroller.text = "Bayad";
        controller.loanacnocontroller.text = "515155514877";
        controller.insurancecontroller.text = "54458542111";
        controller.buffalocountcontroller.text = "4";
        controller.cowcountcontroller.text = "2";
        controller.buffalomoneycontroller.text = "40000";
        controller.cowmoneycontroller.text = "20000";
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: controller.ischangepage == null
                ? 'Cattle Tagging'
                : controller.retagging != null
                ? 'Cattle Retagging'
                : 'Cattle Claim',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: hp(4), right: wp(4), left: wp(4)),
            child: Column(
              children: [
                CustomTextField(
                  controller: controller.namecontroller,
                  backgroundColor: AppColors.WHITE,
                  inputtextcolor: AppColors.PRIMARY_COLOR,
                  readOnly: controller.manualtagging ?? true,
                ),
                SizedBox(height: hp(2)),
                Row(
                  children: [
                    Customcontainer(context: context, text: "M:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.mobilenumbercontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            UrlLauncher.launch(
                              'tel:+${controller.mobilenumbercontroller}',
                            );
                          },
                          child: Icon(
                            Icons.call_sharp,
                            color: AppColors.PRIMARY_COLOR,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: hp(2)),
                Row(
                  children: [
                    Customcontainer(context: context, text: "Add:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.addresscontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: hp(2)),
                Row(
                  children: [
                    Customcontainer(context: context, text: "Vill:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.villegcontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: hp(2)),
                Row(
                  children: [
                    Customcontainer(context: context, text: "Ta:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.talukcontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                      ),
                    ),
                    SizedBox(width: wp(2.5)),
                    Customcontainer(context: context, text: "Di:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.districcontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: hp(2)),
                Row(
                  children: [
                    Customcontainer(context: context, text: "Bank:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.banknamecontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: hp(2)),
                Row(
                  children: [
                    Customcontainer(context: context, text: "Branch:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.branchcontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: hp(2)),
                Row(
                  children: [
                    Customcontainer(context: context, text: "Loan A/c No:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.loanacnocontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: hp(2)),
                Row(
                  children: [
                    Customcontainer(context: context, text: "Insurance Co:"),
                    SizedBox(width: wp(2.5)),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: controller.insurancecontroller,
                        backgroundColor: AppColors.WHITE,
                        inputtextcolor: AppColors.PRIMARY_COLOR,
                        readOnly: controller.manualtagging ?? true,
                      ),
                    ),
                  ],
                ),
                controller.ischangepage == null
                    ? SizedBox(height: hp(4))
                    : SizedBox(height: hp(2)),
                controller.ischangepage == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Customcontainer(
                            context: context,
                            text: "Species",
                            height: hp(4.5),
                            width: wp(22),
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Customcontainer(
                            width: wp(16),
                            context: context,
                            text: "No",
                            height: hp(4.5),
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Customcontainer(
                            context: context,
                            width: wp(48),
                            text: "Sum Insured",
                            height: hp(4.5),
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
                controller.ischangepage == null
                    ? SizedBox(height: hp(2))
                    : SizedBox(),
                controller.ischangepage == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Customcontainer(
                            context: context,
                            width: wp(22),
                            text: "Buffalo",
                            textcolor: Colors.deepPurple,
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              readOnly: controller.buffaloreadOnly,
                              controller: controller.buffalocountcontroller,
                              backgroundColor: AppColors.WHITE,
                              inputtextcolor: Colors.deepPurple,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Expanded(
                            flex: 4,
                            child: CustomTextField(
                              textAlign: TextAlign.center,
                              readOnly: controller.buffaloreadOnly,
                              controller: controller.buffalomoneycontroller,
                              backgroundColor: AppColors.WHITE,
                              inputtextcolor: Colors.deepPurple,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Container(
                            height: hp(7),
                            decoration: BoxDecoration(
                              color: AppColors.WHITE,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                controller.buffaloreadOnly == true;
                              },
                              icon: Icon(
                                Icons.edit,
                                color: AppColors.DARK,
                                size: dp(context, 25),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Customcontainer(
                            context: context,
                            text: "Species",
                            height: hp(4.5),
                            width: wp(30),
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Customcontainer(
                            width: wp(60),
                            context: context,
                            text: controller.retagging != null
                                ? "Old Tag Number"
                                : "Tag Number",
                            height: hp(4.5),
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: hp(2)),
                controller.ischangepage == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Customcontainer(
                            context: context,
                            width: wp(22),
                            text: "Cow",
                            textcolor: Colors.redAccent,
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              textAlign: TextAlign.center,
                              readOnly: controller.cowreadOnly,
                              controller: controller.cowcountcontroller,
                              backgroundColor: AppColors.WHITE,
                              inputtextcolor: Colors.redAccent,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Expanded(
                            flex: 4,
                            child: CustomTextField(
                              textAlign: TextAlign.center,
                              readOnly: controller.cowreadOnly,
                              controller: controller.cowmoneycontroller,
                              backgroundColor: AppColors.WHITE,
                              inputtextcolor: Colors.redAccent,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Container(
                            height: hp(7),
                            decoration: BoxDecoration(
                              color: AppColors.WHITE,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                controller.cowreadOnly == true;
                              },
                              icon: Icon(
                                Icons.edit,
                                color: AppColors.DARK,
                                size: dp(context, 25),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Customcontainer(
                            context: context,
                            text: "Buffalo",
                            height: hp(4.5),
                            width: wp(30),
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          Customcontainer(
                            width: wp(60),
                            context: context,
                            text: "4123421554415",
                            height: hp(4.5),
                            padding: EdgeInsets.only(
                              left: wp(2.5),
                              right: wp(2.5),
                            ),
                          ),
                        ],
                      ),
                controller.ischangepage == null
                    ? SizedBox()
                    : SizedBox(height: hp(2)),
                controller.ischangepage == null
                    ? SizedBox()
                    : Customcontainer(
                        onTap: () {
                          showDialogWithFields(
                            context: context,
                            controller: controller,
                            title: Text(
                              controller.retagging != null
                                  ? "Old Tagging Photo"
                                  : "Tagging Photo",
                              style: TextStyle(
                                color: AppColors.PRIMARY_COLOR,
                                fontSize: dp(context, 20),
                              ),
                            ),
                            content: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),

                              child: SizedBox(
                                height: hp(78),
                                width: wp(70),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: controller.imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: hp(2)),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.PRIMARY_COLOR,
                                          width: wp(1),
                                        ),
                                      ),
                                      child: Image.asset(
                                        controller.imageUrls[index],
                                        fit: BoxFit.fill,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            actions: [],
                          );
                        },
                        context: context,
                        text: controller.retagging != null
                            ? "Old Tagging Photo"
                            : "Tagging Photo",
                        icon: Icons.image_rounded,
                      ),
                controller.ischangepage == null
                    ? SizedBox()
                    : SizedBox(height: hp(2)),
                controller.ischangepage == null
                    ? SizedBox()
                    : Row(
                        children: [
                          Customcontainer(
                            context: context,
                            text: controller.retagging != null
                                ? "Date of Retagging:"
                                : "Date of Death:",
                          ),
                          SizedBox(width: wp(2.5)),
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: controller.dateofdeathcontroller,
                              inputtextcolor: AppColors.PRIMARY_COLOR,
                              readOnly: true,
                              backgroundColor: AppColors.WHITE,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  controller.pickDate(
                                    controller: controller,
                                    context,
                                  );
                                },
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  color: AppColors.PRIMARY_COLOR,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                controller.ischangepage == null
                    ? SizedBox()
                    : SizedBox(height: hp(2)),
                controller.ischangepage == null
                    ? SizedBox()
                    : Row(
                        children: [
                          Customcontainer(
                            context: context,
                            text: controller.retagging != null
                                ? "New Tag No:"
                                : "Time of Death:",
                          ),
                          SizedBox(width: wp(2.5)),
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              keyboardType: TextInputType.number,
                              controller: controller.timeofdeathcontroller,
                              inputtextcolor: AppColors.PRIMARY_COLOR,
                              readOnly: controller.retagging != null
                                  ? false
                                  : true,
                              backgroundColor: AppColors.WHITE,
                              suffixIcon: controller.retagging != null
                                  ? null
                                  : GestureDetector(
                                      onTap: () {
                                        controller.pickTime(
                                          controller: controller,
                                          context,
                                        );
                                      },
                                      child: Icon(
                                        Icons.access_time,
                                        color: AppColors.PRIMARY_COLOR,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: hp(3)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Customcontainer(
                      onTap: () {
                        showDialogWithFields(
                          context: context,
                          controller: controller,
                          title: Text(
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
                          content: SizedBox(
                            height: hp(61),
                            width: wp(70),
                            child: GetBuilder<TaggingdataController>(
                              builder: (controller) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: controller.ischangepage == null
                                          ? controller.taggingreasons.map((
                                              reason,
                                            ) {
                                              return RadioListTile<String>(
                                                activeColor:
                                                    AppColors.PRIMARY_COLOR,
                                                title: Text(reason),
                                                value: reason,
                                                groupValue:
                                                    controller.selectedReason,
                                                onChanged: (value) {
                                                  controller.selectedReason =
                                                      value;
                                                  controller.update();
                                                },
                                              );
                                            }).toList()
                                          : controller.retagging != null
                                          ? controller.retaggingreasons.map((
                                              reason,
                                            ) {
                                              return RadioListTile<String>(
                                                title: Text(reason),
                                                value: reason,
                                                groupValue:
                                                    controller.selectedReason,
                                                onChanged: (value) {
                                                  controller.selectedReason =
                                                      value;
                                                  controller.update();
                                                },
                                              );
                                            }).toList()
                                          : controller.claimreasons.map((
                                              reason,
                                            ) {
                                              return RadioListTile<String>(
                                                title: Text(reason),
                                                value: reason,
                                                groupValue:
                                                    controller.selectedReason,
                                                onChanged: (value) {
                                                  controller.selectedReason =
                                                      value;
                                                  controller.update();
                                                },
                                              );
                                            }).toList(),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            padding:
                                                EdgeInsetsDirectional.symmetric(
                                                  horizontal: wp(1),
                                                  vertical: hp(0.5),
                                                ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.PRIMARY_COLOR,
                                                width: wp(0.5),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child:
                                                controller
                                                        .selectedOther1
                                                        .value ==
                                                    null
                                                ? Icon(
                                                    Icons.camera_alt_outlined,
                                                    color:
                                                        AppColors.PRIMARY_COLOR,
                                                    size: dp(context, 45),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          dp(context, 8),
                                                        ),
                                                    child: Image.file(
                                                      controller
                                                          .selectedOther1
                                                          .value!,
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
                                            padding:
                                                EdgeInsetsDirectional.symmetric(
                                                  horizontal: wp(1),
                                                  vertical: hp(0.5),
                                                ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.PRIMARY_COLOR,
                                                width: wp(0.5),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child:
                                                controller
                                                        .selectedOther2
                                                        .value ==
                                                    null
                                                ? Icon(
                                                    Icons.camera_alt_outlined,
                                                    color:
                                                        AppColors.PRIMARY_COLOR,
                                                    size: dp(context, 45),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          dp(context, 8),
                                                        ),
                                                    child: Image.file(
                                                      controller
                                                          .selectedOther2
                                                          .value!,
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
                                            padding:
                                                EdgeInsetsDirectional.symmetric(
                                                  horizontal: wp(1),
                                                  vertical: hp(0.5),
                                                ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.PRIMARY_COLOR,
                                                width: wp(0.5),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child:
                                                controller
                                                        .selectedOther3
                                                        .value ==
                                                    null
                                                ? Icon(
                                                    Icons.camera_alt_outlined,
                                                    color:
                                                        AppColors.PRIMARY_COLOR,
                                                    size: dp(context, 45),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          dp(context, 8),
                                                        ),
                                                    child: Image.file(
                                                      controller
                                                          .selectedOther3
                                                          .value!,
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
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Customcontainer(
                                  onTap: () {
                                    if (controller.selectedReason != null ||
                                        controller.selectedOther1.value !=
                                            null) {
                                      showDialogWithFields(
                                        context: context,
                                        controller: controller,
                                      );
                                    }
                                  },
                                  context: context,
                                  width: wp(33),
                                  text: "Yes",
                                  textcolor: AppColors.WHITE,
                                  color: Colors.red,
                                ),
                                SizedBox(width: wp(2)),
                                Customcontainer(
                                  onTap: () {
                                    Get.back();
                                  },
                                  width: wp(33),
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
                      context: context,
                      width: wp(44),
                      text: controller.ischangepage == null
                          ? "Lead Cancel"
                          : controller.retagging != null
                          ? "RT Cancel"
                          : "Claim Cancel",
                      icon: Icons.cancel_presentation_sharp,
                      padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                    ),
                    SizedBox(width: wp(3)),
                    Customcontainer(
                      onTap: () {
                        Get.dialog(
                          Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          barrierDismissible: false,
                        );

                        Future.delayed(Duration(seconds: 3), () {
                          Get.back(); // close loading dialog
                          Get.toNamed(
                            routekycpage,
                            arguments: {
                              "tagging": Get.arguments["tagging"],
                              "ischangepage": controller.ischangepage,
                              "retagging": controller.retagging,
                            },
                          );
                        });
                      },
                      context: context,
                      width: wp(44),
                      text: "Next",
                      icon: Icons.arrow_forward_sharp,
                      padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                    ),
                  ],
                ),

                SizedBox(height: hp(3)),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
                  ? "Retagging Cancel"
                  : "Claim Cancel",
              textAlign: TextAlign.center,
            ),
        content:
            content ??
            Text(
              controller.ischangepage == null
                  ? "Are You Sure You want to Cancel Lead."
                  : controller.retagging != null
                  ? "Are You Sure You want to Cancel Retagging."
                  : "Are You Sure You want to Cancel Claim.",
              textAlign: TextAlign.center,
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
                    onTap: () {
                      Get.offAllNamed('/homepage');
                    },
                    context: context,
                    width: wp(33),
                    text: "Yes",
                    textcolor: AppColors.WHITE,
                    color: Colors.red,
                  ),
                  SizedBox(width: wp(2)),
                  Customcontainer(
                    onTap: () {
                      Get.back();
                    },
                    width: wp(33),
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
