import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/widgets/custom_camera_button.dart';
import 'package:rrm/widgets/custom_row.dart';
import 'package:rrm/pages/kyc/kyc_controller.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/text_field.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(
      builder: (controller) {
        final ownerName = controller.ownerName;
        final mobileNo = controller.mobileNo;

        if (ownerName.isEmpty && mobileNo.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("No tagging data provided.")),
          );
        }
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: controller.ischangepage == null
                ? 'KYC'
                : controller.retagging != null
                ? 'RETAGGING KYC'
                : 'CLAIM KYC',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(top: hp(4), right: wp(4), left: wp(4)),
              child: Column(
                children: [
                  CustomTextField(
                    controller: controller.namecontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: AppColors.PRIMARY_COLOR,
                    readOnly: true,
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    children: [
                      Customcontainer(context: context, text: "M:"),
                      SizedBox(width: wp(2.5)),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: controller.mobilecontroller,
                          backgroundColor: AppColors.WHITE,
                          inputtextcolor: AppColors.PRIMARY_COLOR,
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hp(2)),
                  customRow(
                    videoicon: false,
                    isvideoimag: false,
                    context: context,
                    controller: controller,
                    textdata: "Front Side of Aadhar card",
                    childimage:
                        controller.selectedAadharfront.value != null
                        ? Image.file(
                            controller.selectedAadharfront.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),
                    image: "assets/kyc/addhar_front.png",

                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 1,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: false,
                    context: context,
                    controller: controller,
                    textdata: "Back Side of Aadhar card",
                    childimage:
                        controller.selectedAadharback.value != null
                        ? Image.file(
                            controller.selectedAadharback.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),
                    image: "assets/kyc/addhar_back.png",
                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 2,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: false,
                    context: context,
                    controller: controller,
                    textdata: "Front Side of Pan card",
                    childimage:
                        controller.selectedPanfront.value != null
                        ? Image.file(
                            controller.selectedPanfront.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),
                    image: "assets/kyc/pan_card.jpg",

                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 3,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: false,
                    context: context,
                    controller: controller,
                    textdata: "Add Bank Details 1",
                    childimage:
                        controller.selectedbankdetails1.value != null
                        ? Image.file(
                            controller.selectedbankdetails1.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),
                    image: "assets/kyc/passbook.jpeg",
                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 4,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: false,
                    context: context,
                    controller: controller,
                    textdata: "Add Bank Details 2",
                    childimage:
                        controller.selectedbankdetails2.value != null
                        ? Image.file(
                            controller.selectedbankdetails2.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),
                    image: "assets/kyc/passbook.jpeg",

                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 5,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: true,
                    context: context,
                    controller: controller,
                    textdata: "Other",
                    childimage:
                        controller.selectedOther5.value != null
                        ? Image.file(
                            controller.selectedOther5.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),
                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 6,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: true,
                    context: context,
                    controller: controller,
                    textdata: "Other",
                    childimage:
                        controller.selectedOther1.value != null
                        ? Image.file(
                            controller.selectedOther1.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),

                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 7,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: true,
                    context: context,
                    controller: controller,
                    textdata: "Other",
                    childimage:
                        controller.selectedOther2.value != null
                        ? Image.file(
                            controller.selectedOther2.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),
                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 8,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: true,
                    context: context,
                    controller: controller,
                    textdata: "Other",
                    childimage:
                        controller.selectedOther3.value != null
                        ? Image.file(
                            controller.selectedOther3.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),

                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 9,
                      );
                    },
                  ),
                  SizedBox(height: hp(1)),
                  customRow(
                    videoicon: false,
                    isvideoimag: true,
                    context: context,
                    controller: controller,
                    textdata: "Other",
                    childimage:
                        controller.selectedOther4.value != null
                        ? Image.file(
                            controller.selectedOther4.value!,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),

                    onTap: () {
                      custombuttomsheet(
                        context: context,
                        controller: controller,
                        isimage: 10,
                      );
                    },
                  ),
                  SizedBox(height: hp(3)),
                  Customcontainer(
                    onTap: () {
                      controller.savekyc();
                      // print("retagging   ::: ${controller.retagging}");
                      // print("ischangepage   ::: ${controller.ischangepage}");
                    },
                    context: context,
                    text: "Save & Next",
                    singlefontSize: dp(context, 20),
                  ),
                  SizedBox(height: hp(3)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
