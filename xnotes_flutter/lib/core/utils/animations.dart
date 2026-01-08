import 'dart:math';

import 'package:flutter/material.dart';

Widget flipAnimation({
  required Widget widget,
  required Animation<double> animation,
  bool isRight = true,
  required bool isFront,
}) {
  final rotateAnim = Tween(begin: pi, end: 0).animate(animation);
  return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(isFront)) != widget?.key;
        var tilt = ((animation.value - 0.5).abs() - 0.4) * 0.003;
        tilt *= isUnder ? (isRight ? -1.0 : 1.0) : 1.0;
        final value = isUnder
            ? min(rotateAnim.value, pi / 2).toDouble()
            : rotateAnim.value.toDouble();
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          child: widget,
          alignment: Alignment.center,
        );
      });
}

Widget halfAnimation({
  required Widget widget,
  required Animation<double> animation,
  double end = 0,
}) {
  final rotateAnim = Tween(begin: 0, end: end);
  return TweenAnimationBuilder(
    tween: rotateAnim,
    builder: (context, val, __) {
      return Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..setEntry(0, 3, 200 * val.toDouble())
          ..rotateY((pi / 6) * val.toDouble()),
        child: widget,
        alignment: Alignment.center,
      );
    },
    duration: const Duration(
      milliseconds: 500,
    ),
  );
}