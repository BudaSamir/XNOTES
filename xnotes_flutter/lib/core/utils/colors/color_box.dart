import 'package:flutter/cupertino.dart';
import 'package:xnotes_flutter/core/utils/colors/app_colors.dart';

Widget colorBox({
  required Widget child,
  double radiusLeft = 0,
  double radiusRight = 0,
}) {
  return Container(
    decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: AppColors.white.withOpacity(0.6),
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset(-2, 5))
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusLeft),
          bottomLeft: Radius.circular(radiusLeft),
          topRight: Radius.circular(radiusRight),
          bottomRight: Radius.circular(radiusRight),
        ),
        gradient: const LinearGradient(colors: [
          AppColors.brown,
          AppColors.lightBrown,
        ])),
    child: child,
  );
}