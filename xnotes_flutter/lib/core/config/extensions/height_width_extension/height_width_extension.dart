import 'package:flutter/material.dart';
import 'package:xnotes_flutter/config/extensions/size_extension/size_extension.dart';

extension HeightWidthExtension on BuildContext{
  SizedBox heightBox(double h) => SizedBox(
    height: getSize.height * h,
  );
  SizedBox widthBox(double w)=> SizedBox(
    width: getSize.width * w,
  );
}