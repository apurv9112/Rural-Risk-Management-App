import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rrm/device_controller.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/enum_utils.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/snackbar_widget.dart';

class LoginController extends GetxController {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  final DeviceController deviceController = Get.find();

  bool isemail = true;
  bool isemailerror = true;

  void submitLogin() {
    // Show loading dialog
    Get.dialog(
      Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 60,
        ),
      ),
      barrierDismissible: false,
    );

    // Delay for 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      Get.back(); // close loading dialog
      showSnackBar("Login Successfully", SNACK.SUCCESS);
      Get.offAllNamed(routehomepage);
    });
  }

  void showDeviceDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          titleTextStyle: TextStyle(
            color: AppColors.DARK,
            fontSize: dp(context, 20),
            fontStyle: FontStyle.italic,
          ),
          title: Text(
            "RRM ID",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: dp(context, 22),
              color: AppColors.PRIMARY_COLOR,
            ),
          ),
          content: Text(
            deviceController.deviceId.value,
            textAlign: TextAlign.center,
          ),
          contentTextStyle: TextStyle(
            fontSize: dp(context, 20),
            color: AppColors.DARK,
          ),
          actions: [
            Customcontainer(
              height: hp(5),
              onTap: () {
                Get.back();
              },
              context: context,
              width: double.infinity,
              text: "ok",
              singlefontSize: dp(context, 20),
              textcolor: AppColors.WHITE,
              color: AppColors.PRIMARY_COLOR,
            ),
          ],
        );
      },
    );
  }
}
