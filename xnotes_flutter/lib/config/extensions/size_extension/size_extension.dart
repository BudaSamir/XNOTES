import 'package:flutter/material.dart';

extension SizeExtension on BuildContext{
  Size get getSize => MediaQuery.sizeOf(this);
}