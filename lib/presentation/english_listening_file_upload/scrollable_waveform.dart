import 'package:flutter/material.dart';

import 'waveform_painter.dart';

class ScrollableWaveform extends StatelessWidget {
  const ScrollableWaveform({super.key, required this.waveformData, required this.scrollController});

  final List<double> waveformData;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final waveformPainter = WaveformPainter(waveformData: waveformData);

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.5),
                child: CustomPaint(
                  size: Size(waveformPainter.intrinsicWidth, 400),
                  painter: waveformPainter,
                ),
              ),
            );
          },
        ),
        const Positioned.fill(
          child: IgnorePointer(child: VerticalDivider(color: Colors.red, thickness: 2)),
        ),
      ],
    );
  }
}
