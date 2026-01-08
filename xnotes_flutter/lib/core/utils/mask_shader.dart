import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xnotes_flutter/core/utils/colors/app_colors.dart';

Widget maskShader(
  AnimationController controller, {
  bool isOpenDrawer = false,
  required List<Color> colors,
}) {
  return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              transform: GradientRotation(controller.value * pi * 2),
              tileMode: TileMode.clamp,
              colors: colors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: Container(
            // width: context.getSize.width,
            // height: context.getSize.height,
            decoration: BoxDecoration(
              borderRadius: isOpenDrawer ? BorderRadius.circular(20) : null,
              color: AppColors.white,
            ),
          ),
        );
      });
}