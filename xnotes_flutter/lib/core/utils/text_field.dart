import 'package:flutter/material.dart';
import 'package:xnotes_flutter/core/config/extensions/font_extension/font_extension.dart';
import 'package:xnotes_flutter/core/utils/colors/app_colors.dart';

typedef OnChange = Function(String);
typedef OnTap = Function();
Widget textField({
  required BuildContext context,
  OnChange? onChange,
  OnTap? onTap,
  bool isObsecure = false,
  Widget? suffixIcon,
  TextInputType textInputType = TextInputType.text,
  required String hintText,
  TextEditingController? controller,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide.none,
  );
  return TextFormField(
    keyboardType: textInputType,
    obscureText: isObsecure,
    controller: controller,
    onChanged: onChange,
    onTap: onTap,
    style: TextStyle(
      color: AppColors.brown,
      fontSize: context.font(16),
      fontWeight: FontWeight.normal,
    ),
    decoration: InputDecoration(
      suffixIcon: suffixIcon,
      hintText: hintText,
      fillColor: AppColors.white,
      filled: true,
      border: border,
      errorBorder: border,
      enabledBorder: border,
      focusedBorder: border,
      disabledBorder: border,
      focusedErrorBorder: border,
    ),
  );
}
