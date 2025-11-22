import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';

class CustomTextField extends StatelessWidget {
  final String? labeltext;
  final Function(String)? onchange;
  final TextEditingController? controller;
  final String? hint;
  final Color? backgroundColor;
  final bool? readOnly;
  final Color? bordercolor;
  final String? errorText;
  final InputBorder? errorBorder;
  final MultiValidator? validator;
  final void Function()? onEditingComplete;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;
  final void Function(String)? onFieldSubmitted;
  final TextAlign? textAlign;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool? obscureText;
  final InputBorder? focusedBorder;
  final InputBorder? border;
  final InputBorder? focusedErrorBorder;
  final InputBorder? enabledBorder;
  final Color? inputtextcolor;
  final Widget? suffixIcon;
  final TextStyle? hintStyle;

  const CustomTextField({
    super.key,
    this.controller,
    this.labeltext,
    this.onchange,
    this.hint,
    this.backgroundColor,
    this.readOnly,
    this.bordercolor,
    this.errorBorder,
    this.errorText,
    this.validator,
    this.onEditingComplete,
    this.keyboardType,
    this.focusNode,
    this.autovalidateMode,
    this.onFieldSubmitted,
    this.textAlign,
    this.textCapitalization,
    this.inputFormatters,
    this.textInputAction,
    this.obscureText,
    this.focusedBorder,
    this.border,
    this.focusedErrorBorder,
    this.enabledBorder,
    this.inputtextcolor,
    this.suffixIcon,
    this.hintStyle, // <-- NEW
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlignVertical: TextAlignVertical.center,
      textInputAction: textInputAction,
      cursorColor: AppColors.WHITE,
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText ?? false,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters:
          inputFormatters ?? [FilteringTextInputFormatter.deny(RegExp(r'^\s'))],
      textAlign: textAlign ?? TextAlign.start,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      focusNode: focusNode,
      onChanged: onchange,
      validator: (validator ?? MultiValidator([])).call,
      readOnly: readOnly ?? false,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: labeltext,
        labelStyle: TextStyle(color: Colors.white54),
        hintText: hint ?? "",
        hintStyle:
            hintStyle ??
            TextStyle(color: Colors.white54, fontSize: dp(context, 16)),
        filled: true,
        fillColor:
            backgroundColor ?? AppColors.PRIMARY_COLOR, // <-- Default color
        enabledBorder:
            enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(dp(context, 10)),
              borderSide: BorderSide(
                color: Colors.white,
                style: BorderStyle.solid,
              ),
            ),
        border:
            border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(dp(context, 10)),
              borderSide: BorderSide(
                color: bordercolor ?? Colors.white,
                style: BorderStyle.solid,
                width: wp(2),
              ),
            ),
        focusedBorder:
            focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(dp(context, 10)),
            ),
        focusedErrorBorder:
            focusedErrorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(dp(context, 10)),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),

        errorBorder:
            errorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(dp(context, 10)),
            ),
        errorText: errorText,
        errorStyle: TextStyle(color: Colors.red),
      ),
      style: TextStyle(color: inputtextcolor ?? Colors.white),
    );
  }
}
