import 'package:flutter/material.dart';

extension FontExtension on BuildContext{
  double  font(double fontSize)=> MediaQuery.of(this).textScaler.scale(fontSize);
}