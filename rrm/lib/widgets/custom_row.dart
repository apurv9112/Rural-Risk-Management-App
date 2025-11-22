import 'package:flutter/material.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:super_tooltip/super_tooltip.dart';

customRow({
  required BuildContext context,
  required controller,
  required String textdata,
  // required File file,
  required void Function()? onTap,
  required Widget? childimage,
  String? image,
  bool? isvideoimag,
  bool? videoicon,
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
                width: wp(50),
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
              isvideoimag == false
                  ? SuperTooltip(
                      showBarrier: true,
                      popupDirection: TooltipDirection.left,
                      showDropBoxFilter: true,
                      content: Image.asset(
                        image ?? "asset/images/home_logo_1.png",
                        scale: dp(context, 4),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(dp(context, 2)),
                        margin: EdgeInsets.only(right: wp(2)),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.PRIMARY_COLOR,
                        ),
                        child: Icon(
                          Icons.remove_red_eye_outlined,
                          size: dp(context, 18),
                          color: AppColors.WHITE,
                        ),
                      ),
                    )
                  : SizedBox(),
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
              videoicon == false
                  ? Icons.camera_enhance_rounded
                  : Icons.video_camera_back_rounded,
              color: AppColors.PRIMARY_COLOR,
              size: dp(context, 35),
            ),
          ),
        ),
      ),
    ],
  );
}
