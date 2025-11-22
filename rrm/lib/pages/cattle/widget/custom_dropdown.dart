import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:rrm/utils/colors.dart';

import 'package:rrm/utils/responsive.dart';

customdropdown({
  required BuildContext context,
  required controller,
  required String title,
  required List<DropdownMenuItem<String>>? items,
  void Function(String?)? onSaved,
  void Function(String?)? onChanged,
  String? value,
}) {
  return DropdownButtonFormField2<String>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.WHITE,
      contentPadding: EdgeInsets.symmetric(vertical: dp(context, 10)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    hint: Text(
      title,
      style: TextStyle(fontSize: dp(context, 12), color: AppColors.DARK),
    ),

    items: items,

    onChanged: onChanged,
    onSaved: onSaved,
    buttonStyleData: const ButtonStyleData(padding: EdgeInsets.only(right: 8)),
    iconStyleData: IconStyleData(
      icon: Icon(
        Icons.arrow_circle_down_outlined,
        color: AppColors.PRIMARY_COLOR,
      ),
      iconSize: dp(context, 24),
    ),
    dropdownStyleData: DropdownStyleData(
      decoration: BoxDecoration(
        color: AppColors.WHITE,
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    menuItemStyleData: MenuItemStyleData(
      padding: EdgeInsets.symmetric(horizontal: dp(context, 16)),
    ),
  );
}
