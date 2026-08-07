import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customappbar.dart';
import 'package:rrm/pages/farmer_details/farmer_details_controller.dart';
import 'package:rrm/pages/farmer_details/widget/claim_report_widget.dart';
import 'package:rrm/pages/farmer_details/widget/retagging_report_widget.dart';
import 'package:rrm/pages/farmer_details/widget/tagging_report_widget.dart';

class FarmerDetailsScreen extends StatelessWidget {
  const FarmerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FarmerDetailsController>(
      init: FarmerDetailsController(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.PRIMARY_COLOR,
          appBar: CustomAppBarAction(
            title: 'Report',
            iconleft: Icons.arrow_back_outlined,
            lefticononTap: () {
              Get.back();
            },
            iconright: Icons.share,
            righticononTap: () async {
              await controller.generatePdf(); // Handle share icon tap
            },
          ),
          body: Padding(
            padding: EdgeInsets.only(
              top: hp(4),
              right: wp(4),
              left: wp(4),
              bottom: hp(4),
            ),
            child: RepaintBoundary(
              key: controller.reportKey,
              child: Material(
                color: Colors.white,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  constrained: false,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: buildReport(controller),
                    ),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.WHITE,
            onPressed: () {
              Get.offAllNamed("routehomepage");
            },
            label: Text("Home"),
          ),
        );
      },
    );
  }

  Widget buildReport(FarmerDetailsController controller) {
    switch (controller.type.toLowerCase()) {
      case "tagging":
        return TaggingReportWidget(
          report: controller.report,
          controller: controller,
        );

      case "retagging":
        return RetaggingReportWidget(
          report: controller.report,
          controller: controller,
        );

      case "claim":
        return ClaimReportWidget(
          report: controller.report,
          controller: controller,
        );

      default:
        return const SizedBox();
    }
  }
}

datarow({
  required BuildContext context,
  required String staticdata,
  required String listdata,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        staticdata,
        style: TextStyle(
          fontSize: dp(context, 18),
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        listdata,
        style: TextStyle(
          fontSize: dp(context, 18),
          fontWeight: FontWeight.w300,
        ),
      ),
    ],
  );
}
