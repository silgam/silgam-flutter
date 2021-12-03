import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'analog_clock.dart';

class WristWatchContainer extends StatelessWidget {
  final Widget? child;

  const WristWatchContainer({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 410),
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: AspectRatio(
          aspectRatio: 200 / 330,
          child: child,
        ),
      ),
    );
  }
}

class WristWatch extends StatelessWidget {
  final DateTime clockTime;
  final Function(DateTime)? onEverySecond;
  final bool isLive;

  const WristWatch({
    Key? key,
    required this.clockTime,
    required this.isLive,
    this.onEverySecond,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WristWatchContainer(
      child: Stack(
        children: [
          SvgPicture.asset(
            'assets/wrist_watch.svg',
            fit: BoxFit.fitWidth,
          ),
          Container(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 0.77,
              child: AnalogClock(
                dateTime: clockTime,
                isLive: isLive,
                borderWidth: 0,
                onEverySecond: onEverySecond,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
