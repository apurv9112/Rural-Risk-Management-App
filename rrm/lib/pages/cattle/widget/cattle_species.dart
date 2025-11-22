import 'package:flutter/material.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customcontainer.dart';
import 'package:rrm/widgets/text_field.dart';

iscattlevalue({required BuildContext context, required controller}) {
  return controller.ischangepage == null
      ? Column(
          children: [
            SizedBox(height: hp(1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Customcontainer(
                  width: wp(44.5),
                  context: context,
                  text: "Sum Insured",
                  height: hp(5),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(3)),
                Customcontainer(
                  context: context,
                  width: wp(44.5),
                  text: "Market Value",
                  height: hp(5),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
              ],
            ),
            SizedBox(height: hp(1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    readOnly: controller.buffaloreadOnly,
                    controller: controller.buffalocountcontroller,
                    backgroundColor: AppColors.WHITE,
                  ),
                ),
                SizedBox(width: wp(3)),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    readOnly: controller.buffaloreadOnly,
                    controller: controller.buffalomoneycontroller,
                    backgroundColor: AppColors.WHITE,
                  ),
                ),
              ],
            ),
          ],
        )
      : SizedBox();
}
