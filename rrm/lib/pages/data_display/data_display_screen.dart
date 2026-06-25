import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
        return Scaffold(
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: controller.pageTitle,
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
            iconright: Icons.refresh_outlined,
            righticononTap: () {
              controller.searchcontroller.clear();
              controller.fetchCompletedLeads();
            },
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: controller.formKey,
              child: Padding(
                padding: EdgeInsets.only(top: hp(4), right: wp(4), left: wp(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          controller.searchLeads(
                            controller.searchcontroller.text,
                          );
                        },
                        child: Icon(Icons.search, color: AppColors.WHITE),
                      ),
                      controller: controller.searchcontroller,
                      hint: controller.searchHint,
                      labeltext: controller.searchHint,
                      onchange: (value) {
                        if (value.isEmpty) {
                          controller.filteredLeads = List.from(
                            controller.completedLeads,
                          );
                          controller.update();
                        }
                      },
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) {
                        controller.searchLeads(value);
                      },
                    ),
                    SizedBox(height: hp(2)),

                    if (controller.isLoading || controller.isSearching)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    else if (controller.filteredLeads.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: hp(10)),
                          child: Text(
                            "No data found",
                            style: TextStyle(
                              fontSize: dp(context, 18),
                              color: AppColors.WHITE,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.filteredLeads.length,
                        itemBuilder: (context, i) {
                          final lead =
                              controller.filteredLeads[i]
                                  as Map<String, dynamic>;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.dialog(
                                    Center(
                                      child:
                                          LoadingAnimationWidget.staggeredDotsWave(
                                            color: Colors.white,
                                            size: 60,
                                          ),
                                    ),
                                    barrierColor: Colors.black45,
                                    barrierDismissible: false,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OwnerDatadisplaypage(dataList: lead),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: hp(16),
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: hp(0.5)),
                                            Text(
                                              (lead["ownerName"] ??
                                                      lead["nameOfBeneficiary"] ??
                                                      lead["name"] ??
                                                      "")
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: hp(0.5)),
                                            Text(
                                              (lead["mobileNo"] ??
                                                      lead["phoneNo"] ??
                                                      lead["mobile"] ??
                                                      "")
                                                  .toString(),
                                            ),
                                            SizedBox(height: hp(0.5)),
                                            Text(
                                              (lead["village"] ?? "")
                                                  .toString(),
                                            ),
                                            SizedBox(height: hp(0.5)),
                                            Text(
                                              (lead["taluko"] ??
                                                      lead["taluka"] ??
                                                      "")
                                                  .toString(),
                                            ),
                                            SizedBox(height: hp(0.5)),
                                            Text(
                                              (lead["insuranceCompanyNameAddress"] ??
                                                      "")
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Download certificate icon
                                      GestureDetector(
                                        onTap: () {
                                          final id =
                                              (lead["id"] ?? lead["_id"] ?? "")
                                                  .toString();
                                          if (id.isNotEmpty) {}
                                        },
                                        child: Icon(
                                          Icons.download_rounded,
                                          color: AppColors.PRIMARY_COLOR,
                                          size: dp(context, 24),
                                        ),
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
