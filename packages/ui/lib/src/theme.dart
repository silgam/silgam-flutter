import 'package:flutter/material.dart';

const String defaultFontFamily = 'NanumSquare';

final textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    textStyle: const TextStyle(fontFamily: defaultFontFamily, fontWeight: FontWeight.w700),
  ),
);

final outlinedButtonTheme = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    textStyle: const TextStyle(fontFamily: defaultFontFamily, fontWeight: FontWeight.w700),
  ),
);

SliderThemeData getSliderTheme(BuildContext context) => SliderTheme.of(context).copyWith(
  trackHeight: 3,
  trackShape: const RectangularSliderTrackShape(),
  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
  overlayColor: Colors.transparent,
  thumbShape: SliderComponentShape.noThumb,
  showValueIndicator: ShowValueIndicator.always,
);
