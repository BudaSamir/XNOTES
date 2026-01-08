import 'package:flutter/material.dart';
import 'package:xnotes_flutter/core/config/extensions/size_extension/size_extension.dart';
import 'package:xnotes_flutter/core/utils/colors/app_colors.dart';


Widget background({
  required BuildContext context,
  required Widget child,
  double radius =0,
}) {
  return Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
            color: AppColors.white.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset(-2, 5))
      ],
      color: AppColors.brown,
    ),
    width: context.getSize.width,
    height: context.getSize.height,
    child: child,
  );
}