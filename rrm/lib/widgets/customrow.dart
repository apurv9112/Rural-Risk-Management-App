import 'package:flutter/material.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';

customRow({
  required BuildContext context,
  required controller,
  required String textdata,
  // required File file,
  required void Function()? onTap,
  required Widget? childimage,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        flex: 4,
        child: Container(
          padding: EdgeInsets.only(left: wp(4)),
          height: hp(5.5),
          decoration: BoxDecoration(
            color: AppColors.WHITE,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: wp(60),
                child: Text(
                  textdata,
                  style: TextStyle(
                    fontSize: dp(context, 12),
                    color: AppColors.DARK,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(dp(context, 3)),
                child: childimage,
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
      SizedBox(width: wp(2)),
      Expanded(
        flex: 0,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: hp(0.5), horizontal: wp(1)),
            decoration: BoxDecoration(
              color: AppColors.WHITE,
              border: Border.all(color: AppColors.DARK),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.camera_enhance_rounded,
              color: AppColors.PRIMARY_COLOR,
              size: dp(context, 35),
            ),
          ),
        ),
      ),
    ],
  );
}
