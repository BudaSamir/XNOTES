import 'package:flutter/material.dart';
import 'package:xnotes_flutter/core/utils/app_text.dart';
import 'package:xnotes_flutter/core/utils/colors/app_colors.dart';

ScaffoldFeatureController toast({
  required BuildContext context,
  required String title,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.black,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: appText(context: context, title: title, align: TextAlign.left),
    ),
  );
}
