import 'package:flutter/material.dart' show Colors, IconButton, Icons;
import 'package:flutter/widgets.dart';
import 'package:rrm/pages/tagging_data_screen.dart/tagging_data_controller.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/customcontainer.dart' show Customcontainer;
import 'package:rrm/widgets/text_field.dart';

species({
  required BuildContext context,
  required TaggingdataController controller,
}) {
  return Column(
    children: [
      controller.ischangepage == null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Customcontainer(
                  context: context,
                  text: "Species",
                  height: hp(4.5),
                  width: wp(22),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(2)),
                Customcontainer(
                  width: wp(16),
                  context: context,
                  text: "No",
                  height: hp(4.5),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(2)),
                Customcontainer(
                  context: context,
                  width: wp(48),
                  text: "Sum Insured",
                  height: hp(4.5),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
              ],
            )
          : SizedBox(),
      controller.ischangepage == null ? SizedBox(height: hp(2)) : SizedBox(),
      controller.ischangepage == null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Customcontainer(
                  context: context,
                  width: wp(22),
                  text: "Buffalo",
                  textcolor: Colors.deepPurple,
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(2)),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    bordercolor: controller.showBuffaloError
                        ? Colors.yellow
                        : AppColors.WHITE,

                    errorText: controller.showBuffaloError ? "Required" : null,
                    cursorColor: Colors.deepPurple,
                    readOnly: controller.buffaloreadOnly,
                    controller: controller.buffalocountcontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: Colors.deepPurple,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: wp(2)),
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    bordercolor: controller.showBuffaloError
                        ? Colors.yellow
                        : AppColors.WHITE,

                    errorText: controller.showBuffaloError ? "Required" : null,
                    cursorColor: Colors.deepPurple,
                    textAlign: TextAlign.center,
                    readOnly: controller.buffaloreadOnly,
                    controller: controller.buffalomoneycontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: Colors.deepPurple,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: wp(2)),
                Container(
                  height: hp(6),
                  decoration: BoxDecoration(
                    color: AppColors.WHITE,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.buffaloreadOnly =
                          !(controller.buffaloreadOnly ?? false);
                      controller.update();
                    },
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.DARK,
                      size: dp(context, 25),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Customcontainer(
                  context: context,
                  text: "Species",
                  height: hp(4.5),
                  width: wp(30),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(2)),
                Customcontainer(
                  width: wp(60),
                  context: context,
                  text: controller.retagging != null
                      ? "Old Tag Number"
                      : "Tag Number",
                  height: hp(4.5),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
              ],
            ),
      SizedBox(height: hp(2)),
      controller.ischangepage == null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Customcontainer(
                  context: context,
                  width: wp(22),
                  text: "Cow",
                  textcolor: Colors.redAccent,
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(2)),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    bordercolor: controller.showCowError
                        ? Colors.yellow
                        : AppColors.WHITE,

                    errorText: controller.showCowError ? "Required" : null,
                    cursorColor: Colors.redAccent,
                    textAlign: TextAlign.center,
                    readOnly: controller.cowreadOnly,
                    controller: controller.cowcountcontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: Colors.redAccent,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: wp(2)),
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    bordercolor: controller.showCowError
                        ? Colors.yellow
                        : AppColors.WHITE,

                    errorText: controller.showCowError ? "Required" : null,
                    cursorColor: Colors.redAccent,
                    textAlign: TextAlign.center,
                    readOnly: controller.cowreadOnly,
                    controller: controller.cowmoneycontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: Colors.redAccent,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: wp(2)),
                Container(
                  height: hp(6),
                  decoration: BoxDecoration(
                    color: AppColors.WHITE,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.cowreadOnly =
                          !(controller.cowreadOnly ?? false);
                      controller.update();
                    },
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.DARK,
                      size: dp(context, 25),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Customcontainer(
                  context: context,
                  text: controller.species ?? "",
                  height: hp(4.5),
                  width: wp(30),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(2)),
                Customcontainer(
                  width: wp(60),
                  context: context,
                  text: controller.tagnumberclaim ?? "",
                  height: hp(4.5),
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
              ],
            ),
      controller.ischangepage == null ? SizedBox(height: hp(2)) : SizedBox(),
      controller.ischangepage == null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Customcontainer(
                  context: context,
                  width: wp(22),
                  text: "Goat",
                  textcolor: Colors.brown,
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(2)),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    bordercolor: controller.showGoatError
                        ? Colors.yellow
                        : AppColors.WHITE,

                    errorText: controller.showGoatError ? "Required" : null,
                    cursorColor: Colors.brown,
                    textAlign: TextAlign.center,
                    readOnly: controller.goatoreadOnly,
                    controller: controller.goatcontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: Colors.brown,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: wp(2)),
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    bordercolor: controller.showGoatError
                        ? Colors.yellow
                        : AppColors.WHITE,

                    errorText: controller.showGoatError ? "Required" : null,
                    cursorColor: Colors.brown,
                    textAlign: TextAlign.center,
                    readOnly: controller.goatoreadOnly,
                    controller: controller.goatmoneycontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: Colors.brown,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: wp(2)),

                Container(
                  height: hp(6),
                  decoration: BoxDecoration(
                    color: AppColors.WHITE,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.goatoreadOnly =
                          !(controller.goatoreadOnly ?? false);
                      controller.update();
                    },
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.DARK,
                      size: dp(context, 25),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(),
      controller.ischangepage == null ? SizedBox(height: hp(2)) : SizedBox(),
      controller.ischangepage == null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Customcontainer(
                  context: context,
                  width: wp(22),
                  text: "Sheep",

                  textcolor: Colors.blue,
                  padding: EdgeInsets.only(left: wp(2.5), right: wp(2.5)),
                ),
                SizedBox(width: wp(2)),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    bordercolor: controller.showSheepError
                        ? Colors.yellow
                        : AppColors.WHITE,

                    errorText: controller.showSheepError ? "Required" : null,
                    cursorColor: Colors.blue,
                    textAlign: TextAlign.center,
                    readOnly: controller.sheepreadOnly,
                    controller: controller.sheepcountcontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: Colors.blue,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: wp(2)),
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    bordercolor: controller.showSheepError
                        ? Colors.yellow
                        : AppColors.WHITE,

                    errorText: controller.showSheepError ? "Required" : null,
                    cursorColor: Colors.blue,
                    textAlign: TextAlign.center,
                    readOnly: controller.sheepreadOnly,
                    controller: controller.sheepmoneycontroller,
                    backgroundColor: AppColors.WHITE,
                    inputtextcolor: Colors.blue,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: wp(2)),
                Container(
                  height: hp(6),
                  decoration: BoxDecoration(
                    color: AppColors.WHITE,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.sheepreadOnly =
                          !(controller.sheepreadOnly ?? false);
                      controller.update();
                    },
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.DARK,
                      size: dp(context, 25),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(),
    ],
  );
}
