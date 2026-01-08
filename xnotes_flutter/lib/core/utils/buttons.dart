import 'package:flutter/material.dart';
import 'package:xnotes_flutter/core/config/extensions/size_extension/size_extension.dart';
import 'package:xnotes_flutter/core/utils/app_text.dart';
import 'package:xnotes_flutter/core/utils/colors/app_colors.dart';


typedef OnTap = Function();
Widget textButton({
  required BuildContext context,
  required String title,
  required OnTap onTap,
  Color bgColor = AppColors.black,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
  double vrPadding = 10,
  double? width,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width == null ? context.getSize.width : width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: vrPadding),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white, width: 2)),
      child: appText(
        context: context,
        title: title,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    ),
  );
}

Widget shadowButton({
  required BuildContext context,
  required String title,
  required OnTap onTap,
  Color bgColor = AppColors.black,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
  double vrPadding = 10,
  double? width,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width == null ? context.getSize.width : width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: vrPadding),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: AppColors.white,
                offset: Offset(5, 0),
                blurRadius: 20,
                spreadRadius: 0)
          ],
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white, width: 2)),
      child: appText(
        context: context,
        title: title,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    ),
  );
}