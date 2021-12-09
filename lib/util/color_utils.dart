import 'package:flutter/material.dart';

Color getGradientColor(double t) {
  final startColor = HSVColor.fromColor(const Color(0xFFC67EF2));
  final endColor = HSVColor.fromColor(const Color(0xFF5CA2E8));
  final color = HSVColor.lerp(startColor, endColor, t) ?? HSVColor.fromColor(Colors.white);
  return color.toColor();
}
