import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:rrm/pages/login/login_controller.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/text_field.dart';
import 'package:rrm/dependency_injection.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.PRIMARY_COLOR,
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: dp(context, 50),
              right: dp(context, 12),
              left: dp(context, 12),
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: hp(9)),
                      Image.asset(
                        'assets/images/login_logo.png',
                        height: hp(20),
                      ),
                      SizedBox(height: hp(7)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.isemail = true;
                              controller.update();
                            },
                            child: Text(
                              "Mobile No",
                              style: TextStyle(
                                color: AppColors.WHITE,
                                fontSize: dp(context, 20),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.isemail = false;
                              controller.update();
                            },
                            child: Text(
                              "Email Id",
                              style: TextStyle(
                                color: AppColors.WHITE,
                                fontSize: dp(context, 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: wp(45),
                            child: Divider(
                              color: controller.isemail
                                  ? AppColors.WHITE
                                  : Colors.transparent,
                              thickness: dp(context, 2),
                            ),
                          ),
                          SizedBox(width: wp(2)),
                          SizedBox(
                            width: wp(45),
                            child: Divider(
                              color: !controller.isemail
                                  ? AppColors.WHITE
                                  : Colors.transparent,
                              thickness: dp(context, 2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: hp(2)),
                      controller.isemail
                          ? CustomTextField(
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              controller: controller.mobilecontroller,
                              hint: "Mobile No",
                              labeltext: 'Mobile No',
                              validator: formValidation.validation(
                                type: 'mobileno',
                                multiValidator: MultiValidator([]),
                                isRequired: true,
                                errorText: "Mobile is required.",
                              ),
                            )
                          : CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              controller: controller.emailcontroller,
                              hint: "Email Id",
                              labeltext: 'Email Id',
                              validator: formValidation.validation(
                                type: 'email',
                                multiValidator: MultiValidator([]),
                                isRequired: true,
                                errorText: "Email is required.",
                              ),
                            ),
                      SizedBox(height: hp(2)),
                      CustomTextField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: controller.passwordcontroller,
                        textInputAction: TextInputAction.done,
                        hint: 'Password',
                        labeltext: 'Password',
                        obscureText: !controller.isPasswordVisible,

                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.WHITE,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        validator: formValidation.validation(
                          type: 'password',
                          multiValidator: MultiValidator([]),
                          isRequired: true,
                          errorText: "Password is required.",
                        ),
                      ),
                      SizedBox(height: hp(4)),
                      Customcontainer(
                        context: context,
                        text: "Login",
                        singlefontSize: dp(context, 25),
                        onTap: controller.submitLogin,
                      ),
                    ],
                  ),
                  SizedBox(height: hp(18)),
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://ruralrisk.in/privacy-policy.html',
                      );

                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: AppColors.WHITE,
                        fontSize: dp(context, 8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: hp(10), top: hp(1)),
                    child: Image.asset(
                      'assets/images/DCI.png',
                      scale: dp(context, 2.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
