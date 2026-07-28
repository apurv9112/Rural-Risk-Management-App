import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
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
                SizedBox(
                  width: wp(44.5),
                  child: CustomTextField(
                    cursorColor: AppColors.PRIMARY_COLOR,
                    inputtextcolor: AppColors.PRIMARY_COLOR,
                    keyboardType: TextInputType.number,
                    readOnly: controller.buffaloreadOnly,
                    controller: controller.sumInsuredController,
                    backgroundColor: AppColors.WHITE,
                  ),
                ),
                SizedBox(width: wp(3)),
                SizedBox(
                  width: wp(44.5),
                  child: CustomTextField(
                    cursorColor: AppColors.PRIMARY_COLOR,
                    inputtextcolor: AppColors.PRIMARY_COLOR,
                    keyboardType: TextInputType.number,
                    readOnly: controller.buffaloreadOnly,
                    controller: controller.marketValueController,
                    focusNode: controller.marketValueFocusNode,
                    validator: controller.isSuccessfullyTagging
                        ? MultiValidator([
                            RequiredValidator(errorText: "Required"),
                          ])
                        : null,
                    backgroundColor: AppColors.WHITE,
                  ),
                ),
              ],
            ),
          ],
        )
      : SizedBox();
}
