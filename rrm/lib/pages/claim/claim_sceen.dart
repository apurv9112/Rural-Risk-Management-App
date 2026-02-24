import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/claim/claim_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/widgets/customcontainer.dart';

class ClaimScreen extends StatelessWidget {
  const ClaimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClaimController>(
      init: ClaimController(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: controller.isRetagging
                ? 'Cattle Retagging'
                : 'Cattle Claim',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
            iconright: Icons.refresh_outlined,
            righticononTap: () {
              controller.fetchLeads();
            },
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : controller.leads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: AppColors.WHITE),
                          SizedBox(height: hp(2)),
                          Text(
                            controller.isRetagging
                                ? "No retagging leads assigned"
                                : "No claim leads assigned",
                            style: TextStyle(
                              fontSize: dp(context, 18),
                              color: AppColors.WHITE,
                            ),
                          ),
                          SizedBox(height: hp(2)),
                          Customcontainer(
                            context: context,
                            text: "Refresh",
                            singlefontSize: dp(context, 18),
                            onTap: () => controller.fetchLeads(),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: hp(4),
                        right: wp(4),
                        left: wp(4),
                        bottom: hp(4),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: hp(5.5),
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              right: wp(2),
                              left: wp(4),
                              top: hp(0.5),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.DARK),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.WHITE,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${controller.leads.length}",
                                  style: TextStyle(
                                    fontSize: dp(context, 17),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: wp(2)),
                                SizedBox(
                                  height: hp(12),
                                  child: VerticalDivider(
                                    color: AppColors.LIGHT_GREY,
                                  ),
                                ),
                                SizedBox(width: wp(2)),
                                Text(
                                  controller.isRetagging
                                      ? 'Total Retagging Leads'
                                      : 'Total Claim Leads',
                                  style: TextStyle(
                                    fontSize: dp(context, 17),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: hp(2)),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: controller.leads.length,
                            itemBuilder: (context, i) {
                              final lead = controller.leads[i] as Map<String, dynamic>;
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final id = (lead["_id"] ?? lead["id"] ?? "").toString();
                                      if (id.isEmpty) return;

                                      final details = await controller.getLeadDetails(id);
                                      if (details != null) {
                                        Get.toNamed(
                                          routetaggingdatapage,
                                          arguments: {
                                            "tagging": details,
                                            "isclaim": controller.isRetagging ? null : controller.claim,
                                            "retagging": controller.retagging,
                                          },
                                        );
                                      }
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: hp(0.5)),
                                                Text(
                                                  (lead["ownerName"] ?? "").toString(),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: hp(0.5)),
                                                Text(
                                                  (lead["mobileNo"] ?? "").toString(),
                                                ),
                                                SizedBox(height: hp(0.5)),
                                                Text(
                                                  (lead["village"] ?? "").toString(),
                                                ),
                                                SizedBox(height: hp(0.5)),
                                                Text(
                                                  (lead["taluko"] ?? "").toString(),
                                                ),
                                                SizedBox(height: hp(0.5)),
                                                Text(
                                                  (lead["insuranceCompanyName"] ?? "").toString(),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
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
        );
      },
    );
  }
}
