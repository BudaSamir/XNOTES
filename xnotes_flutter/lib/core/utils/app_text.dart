import 'package:flutter/material.dart';
import 'package:xnotes_flutter/core/config/extensions/font_extension/font_extension.dart';
import 'package:xnotes_flutter/core/utils/colors/app_colors.dart';

Widget appText({
  required BuildContext context,
  required String title,
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.normal,
  Color color = AppColors.white,
  TextAlign align = TextAlign.center,
  int maxLines = 2,
}) {
  return Text(
    title,
    textAlign: align,
    maxLines: maxLines,
    style: TextStyle(
      fontSize: context.font(fontSize),
      fontWeight: fontWeight,
      color: color,
    ),
  );
}
