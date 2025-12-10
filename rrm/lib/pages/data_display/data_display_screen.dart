import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/data_display/data_display_controller.dart';
import 'package:rrm/pages/data_display/owner_data_display.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/widgets/text_field.dart';

class Datadisplaypage extends StatelessWidget {
  const Datadisplaypage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DatadisplayController>(
      init: DatadisplayController(),
      builder: (controller) {
        final args = Get.arguments;
        // print("args ;;;; $args");
        controller.retaggingdata = args != null ? "retaggingdata" : null;
        // controller.taggingdata = args != null ? "taggingdata" : null;
        controller.claimdata = args != null ? "claimdata" : null;
        return Scaffold(
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: controller.claimdata == null
                ? 'Tagging Data'
                : controller.retaggingdata != null
                ? 'Claim Data'
                : 'Retagging Data',

            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Form(
              key: controller.formKey,
              child: Padding(
                padding: EdgeInsets.only(top: hp(4), right: wp(4), left: wp(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      suffixIcon: Icon(Icons.search, color: AppColors.WHITE),
                      controller: controller.searchcontroller,
                      hint: 'Search Tagging Data',
                      labeltext: 'Search Tagging Data',
                      onchange: (p0) => controller.searchcontroller,
                      textInputAction: TextInputAction.search,
                    ),
                    SizedBox(height: hp(2)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: controller.textList.length,
                      itemBuilder: (context, i) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OwnerDatadisplaypage(
                                      dataList: controller.textList[i],
                                    ),
                                  ),
                                );
                                // Get.toNamed(
                                //   routetaggingdatapage,
                                //   arguments: {"tagging": controller.textList[i]},
                                // );
                                // print(controller.textList[i]);
                              },
                              child: Container(
                                height: hp(16),
                                // width: wp(80),
                                width: double.infinity,
                                padding: EdgeInsets.only(
                                  right: wp(2),
                                  left: wp(4),
                                  top: hp(1),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.DARK),
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.WHITE,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: wp(2)),
                                    Center(
                                      child: Text(
                                        "${i + 1}",
                                        style: TextStyle(
                                          fontSize: dp(context, 18),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: wp(2.2)),
                                    SizedBox(
                                      height: hp(12),
                                      child: VerticalDivider(
                                        color: AppColors.LIGHT_GREY,
                                      ),
                                    ),
                                    SizedBox(width: wp(2.2)),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: hp(0.5)),
                                        Text(controller.textList[i]["name"]!),
                                        SizedBox(height: hp(0.5)),
                                        Text(controller.textList[i]["mobile"]!),
                                        SizedBox(height: hp(0.5)),
                                        Text(
                                          controller.textList[i]["village"]!,
                                        ),
                                        SizedBox(height: hp(0.5)),
                                        Text(controller.textList[i]["taluko"]!),
                                        SizedBox(height: hp(0.5)),
                                        Text(
                                          controller.textList[i]["Insurance"]!,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: hp(1)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
