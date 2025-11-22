import 'package:flutter/material.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';

class Customcontainer extends StatelessWidget {
  final BuildContext context;
  final String text;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;
  final void Function()? onTap;
  final Color? color;
  final Color? textcolor;
  final double? singlefontSize;
  const Customcontainer({
    super.key,
    required this.context,
    required this.text,
    this.height,
    this.padding,
    this.icon,
    this.color,
    this.textcolor,
    this.width,
    this.singlefontSize,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? hp(7),
        width: width,
        decoration: BoxDecoration(
          color: color ?? AppColors.WHITE,
          borderRadius: BorderRadius.circular(10),
        ),

        padding: padding ?? EdgeInsets.only(right: wp(2), left: wp(2.5)),
        child: icon == null
            ? Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: singlefontSize ?? dp(context, 14),
                    color: textcolor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: dp(context, 30),
                    color: AppColors.PRIMARY_COLOR,
                  ),
                  SizedBox(width: wp(2)),
                  Text(
                    text,
                    style: TextStyle(
                      color: AppColors.PRIMARY_COLOR,
                      fontSize: dp(context, 16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
