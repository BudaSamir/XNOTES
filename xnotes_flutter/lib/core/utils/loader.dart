import 'package:flutter/material.dart';
import 'package:xnotes_flutter/core/utils/colors/app_colors.dart';

loader({double size = 35}) {
  return SizedBox(
    width: size,
    height: size,
    child: const FittedBox(
      child: CircularProgressIndicator(
        color: AppColors.white,
        strokeWidth: 2,
      ),
    ),
  );
}