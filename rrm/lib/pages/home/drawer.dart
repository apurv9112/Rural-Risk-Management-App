import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/pages/home/home_page.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:get_it/get_it.dart';
import 'package:rrm/services/offline/queue_statistics_service.dart';

customdrawer({required BuildContext context}) {
  return Drawer(
    backgroundColor: AppColors.WHITE,
    child: ListView(
      children: [
        SizedBox(
          height: hp(6),
          child: DrawerHeader(
            padding: EdgeInsetsGeometry.only(
              top: hp(1),
              left: wp(5),
              bottom: hp(1),
              right: wp(3),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "RRM DATA BASE",
                  style: TextStyle(
                    fontSize: dp(context, 22),
                    color: AppColors.PRIMARY_COLOR,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialoglogout(context: context);
                  },
                  child: Image.asset(
                    "assets/images/logout.png",
                    color: AppColors.PRIMARY_COLOR,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: hp(2)),
        customcontainer(
          padding: EdgeInsets.symmetric(horizontal: wp(3)),
          margin: EdgeInsets.symmetric(horizontal: wp(4)),
          onTap: () {
            Get.toNamed(routeDatadisplaypage);
          },
          // arguments: "taggingdata"
          context: context,
          logo: 'assets/images/home_logo_1.png',
          rowwidth: wp(5),
          name: "TAGGING \nDATA",
        ),
        SizedBox(height: hp(3)),
        customcontainer(
          padding: EdgeInsets.symmetric(horizontal: wp(3)),
          margin: EdgeInsets.symmetric(horizontal: wp(4)),
          onTap: () {
            Get.toNamed(routeDatadisplaypage, arguments: "claimdata");
          },
          logo: 'assets/images/home_logo_2.png',
          rowwidth: wp(6),
          name: 'CLAIM \nDATA',
          context: context,
        ),
        SizedBox(height: hp(3)),
        customcontainer(
          padding: EdgeInsets.symmetric(horizontal: wp(2)),
          margin: EdgeInsets.symmetric(horizontal: wp(3.5)),
          onTap: () {
            Get.toNamed(routeDatadisplaypage, arguments: "retaggingdata");
          },
          logo: 'assets/images/home_logo_3.png',
          rowwidth: wp(1.5),
          name: "RETAGGING\nDATA",
          context: context,
        ),
        SizedBox(height: hp(3)),
        _buildSyncStatusDrawerItem(context),
        SizedBox(height: hp(10)),
        Image.asset(
          'assets/images/splash_logo.png',
          height: hp(5),
          color: AppColors.PRIMARY_COLOR,
        ),
      ],
    ),
  );
}

void showDialoglogout({required BuildContext context}) {
  final AppController appController = Get.find();
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        titleTextStyle: TextStyle(
          color: Colors.red,
          fontSize: dp(context, 24),
          fontStyle: FontStyle.italic,
        ),
        title: Text("Logout", textAlign: TextAlign.center),
        content: Text(
          "Are You Sure You want to Logout.",
          textAlign: TextAlign.center,
        ),
        contentTextStyle: TextStyle(
          fontSize: dp(context, 15),
          color: AppColors.DARK,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Customcontainer(
                onTap: () {
                  appController.clearToken();
                  Get.offAllNamed('/loginpage');
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

Widget _buildSyncStatusDrawerItem(BuildContext context) {
  final stats = GetIt.I<QueueStatisticsService>();

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(dp(context, 15)),
      border: Border.all(color: AppColors.DARK),
      color: AppColors.WHITE,
    ),
    padding: EdgeInsets.symmetric(horizontal: wp(3), vertical: hp(1)),
    margin: EdgeInsets.symmetric(horizontal: wp(3.5)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.sync,
              size: dp(context, 40),
              color: AppColors.PRIMARY_COLOR,
            ),
            SizedBox(width: wp(3)),
            Text(
              "SYNC \nSTATUS",
              style: TextStyle(
                fontSize: dp(context, 18),
                color: AppColors.PRIMARY_COLOR,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(height: hp(1)),
        Obx(() {
          int pending =
              stats.pendingSyncCount.value + stats.pendingMediaCount.value;
          int uploading =
              stats.syncingSyncCount.value + stats.uploadingMediaCount.value;
          int failed =
              stats.failedSyncCount.value + stats.failedMediaCount.value;
          int completed =
              stats.completedSyncCount.value + stats.completedMediaCount.value;
          String lastSuccess =
              stats.lastSuccessfulSyncTime.value?.toString().split('.').first ??
              'Never';
          String lastFailed =
              stats.lastFailedSyncTime.value?.toString().split('.').first ??
              'Never';
          String health = stats.queueIntegrityStatus;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pending: $pending',
                style: TextStyle(
                  fontSize: dp(context, 14),
                  color: AppColors.DARK,
                ),
              ),
              Text(
                'Uploading: $uploading',
                style: TextStyle(
                  fontSize: dp(context, 14),
                  color: AppColors.DARK,
                ),
              ),
              Text(
                'Failed: $failed',
                style: TextStyle(
                  fontSize: dp(context, 14),
                  color: AppColors.DARK,
                ),
              ),
              Text(
                'Completed: $completed',
                style: TextStyle(
                  fontSize: dp(context, 14),
                  color: AppColors.DARK,
                ),
              ),
              SizedBox(height: hp(0.5)),
              Text(
                'Last Success: $lastSuccess',
                style: TextStyle(fontSize: dp(context, 12), color: Colors.grey),
              ),
              Text(
                'Last Failed: $lastFailed',
                style: TextStyle(fontSize: dp(context, 12), color: Colors.grey),
              ),
              Text(
                'Queue Health: $health',
                style: TextStyle(
                  fontSize: dp(context, 12),
                  color: health == 'Warning'
                      ? Colors.orange
                      : (health == 'Critical' ? Colors.red : Colors.green),
                ),
              ),
            ],
          );
        }),
      ],
    ),
  );
}
