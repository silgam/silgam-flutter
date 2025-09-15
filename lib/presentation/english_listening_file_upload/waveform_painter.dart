import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color waveColor;
  final double barWidth;
  final double gapWidth;

  const WaveformPainter({
    required this.waveformData,
    this.waveColor = Colors.blue,
    this.barWidth = 2,
    this.gapWidth = 2,
  });

  double get intrinsicWidth {
    if (waveformData.isEmpty) return 0;
    return waveformData.length * (barWidth + gapWidth) - gapWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = barWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final maxAmplitude = waveformData.max;
    final normalizer = maxAmplitude == 0 ? 1 : maxAmplitude;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * (barWidth + gapWidth) + barWidth / 2;
      final normalizedAmplitude = waveformData[i] / normalizer;
      final barHeight = normalizedAmplitude * centerY;

      canvas.drawLine(Offset(x, centerY - barHeight), Offset(x, centerY + barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
        oldDelegate.waveColor != waveColor ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.gapWidth != gapWidth;
  }
}
