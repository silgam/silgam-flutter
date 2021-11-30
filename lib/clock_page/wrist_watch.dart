import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'analog_clock.dart';

class WristWatch extends StatelessWidget {
  final DateTime clockTime;
  final Function(DateTime)? onEverySecond;

  const WristWatch({
    Key? key,
    required this.clockTime,
    this.onEverySecond,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 330,
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
                borderWidth: 0,
                dateTime: clockTime,
                onEverySecond: onEverySecond,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
