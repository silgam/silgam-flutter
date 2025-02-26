import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WristWatch extends StatelessWidget {
  final DateTime clockTime;

  const WristWatch({super.key, required this.clockTime});

  @override
  Widget build(BuildContext context) {
    return WristWatchContainer(
      child: Stack(
        children: [
          SvgPicture.asset('assets/wrist_watch.svg', fit: BoxFit.fitWidth),
          Container(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 0.77,
              child: AnalogClock(clockTime: clockTime, borderWidth: 0),
            ),
          ),
        ],
      ),
    );
  }
}

class WristWatchContainer extends StatelessWidget {
  final Widget? child;

  const WristWatchContainer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 410),
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: AspectRatio(aspectRatio: 200 / 330, child: child),
      ),
    );
  }
}

class AnalogClock extends StatelessWidget {
  final DateTime clockTime;
  final Color dialPlateColor;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color numberColor;
  final Color borderColor;
  final Color tickColor;
  final Color centerPointColor;
  final bool showBorder;
  final bool showTicks;
  final bool showMinuteHand;
  final bool showSecondHand;
  final bool showNumber;
  final double? borderWidth;
  final double hourNumberScale;
  final List<String> hourNumbers;
  final double width;
  final double height;
  final BoxDecoration decoration;
  final Widget? child;

  const AnalogClock({
    required this.clockTime,
    this.dialPlateColor = Colors.white,
    this.hourHandColor = Colors.black,
    this.minuteHandColor = Colors.black,
    this.secondHandColor = Colors.black,
    this.numberColor = Colors.black,
    this.borderColor = Colors.black,
    this.tickColor = Colors.black,
    this.centerPointColor = Colors.black,
    this.showBorder = true,
    this.showTicks = true,
    this.showMinuteHand = true,
    this.showSecondHand = true,
    this.showNumber = true,
    this.borderWidth,
    this.hourNumberScale = 1.0,
    this.hourNumbers = AnalogClockPainter.defaultHourNumbers,
    this.width = double.infinity,
    this.height = double.infinity,
    this.decoration = const BoxDecoration(),
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: CustomPaint(
        painter: AnalogClockPainter(
          clockTime,
          dialPlateColor: dialPlateColor,
          hourHandColor: hourHandColor,
          minuteHandColor: minuteHandColor,
          secondHandColor: secondHandColor,
          numberColor: numberColor,
          borderColor: borderColor,
          tickColor: tickColor,
          centerPointColor: centerPointColor,
          showBorder: showBorder,
          showTicks: showTicks,
          showMinuteHand: showMinuteHand,
          showSecondHand: showSecondHand,
          showNumber: showNumber,
          borderWidth: borderWidth,
          hourNumberScale: hourNumberScale,
          hourNumbers: hourNumbers,
        ),
        child: child,
      ),
    );
  }
}

class AnalogClockPainter extends CustomPainter {
  static const List<String> defaultHourNumbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];
  final DateTime _dateTime;
  final Color dialPlateColor;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color numberColor;
  final Color borderColor;
  final Color tickColor;
  final Color centerPointColor;
  final bool showBorder;
  final bool showTicks;
  final bool showMinuteHand;
  final bool showSecondHand;
  final bool showNumber;
  final double hourNumberScale;
  final List<String> hourNumbers;
  final double? _borderWidth;
  final TextPainter _hourTextPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  AnalogClockPainter(
    this._dateTime, {
    this.dialPlateColor = Colors.transparent,
    this.hourHandColor = Colors.black,
    this.minuteHandColor = Colors.black,
    this.secondHandColor = Colors.black,
    this.numberColor = Colors.black,
    this.borderColor = Colors.black,
    this.tickColor = Colors.black,
    this.centerPointColor = Colors.black,
    this.showBorder = true,
    this.showTicks = true,
    this.showMinuteHand = true,
    this.showSecondHand = true,
    this.showNumber = true,
    this.hourNumberScale = 1.0,
    this.hourNumbers = defaultHourNumbers,
    double? borderWidth,
  }) : assert(hourNumbers.length == 12),
       _borderWidth = borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    //clock radius
    final radius = min(size.width, size.height) / 2;
    //clock circumference
    final double borderWidth =
        showBorder ? (_borderWidth ?? radius / 20.0) : 0.0;
    final double circumference = 2 * (radius - borderWidth) * pi;

    canvas.translate(size.width / 2, size.height / 2);

    canvas.drawCircle(
      const Offset(0, 0),
      radius,
      Paint()
        ..style = PaintingStyle.fill
        ..color = dialPlateColor,
    );

    // border style
    if (showBorder && borderWidth > 0) {
      Paint borderPaint =
          Paint()
            ..color = borderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderWidth
            ..isAntiAlias = true;
      canvas.drawCircle(
        const Offset(0, 0),
        radius - borderWidth / 2,
        borderPaint,
      );
    }

    // setup tick
    final double tickWidth = circumference / 200;
    final double bigTickWidth = circumference / 120;
    final double tickRadius = (radius - borderWidth - bigTickWidth);
    if (showTicks) _paintTicks(canvas, tickRadius, tickWidth, bigTickWidth);

    // setup numbers
    final double numberRadius = tickRadius - bigTickWidth * 3.5;
    double hourTextHeight = (radius - borderWidth) / 4.5 * hourNumberScale;

    if (showNumber) {
      hourTextHeight = _paintHourText(canvas, numberRadius, hourTextHeight);
    }

    _paintHourHand(
      canvas,
      numberRadius - hourTextHeight,
      (radius - borderWidth) / 20,
    );

    if (showMinuteHand) {
      _paintMinuteHand(canvas, numberRadius, (radius - borderWidth) / 40);
    }
    if (showSecondHand) {
      _paintSecondHand(
        canvas,
        numberRadius + hourTextHeight / 2,
        (radius - borderWidth) / 80,
      );
    }

    //draw center point
    Paint centerPointPaint =
        Paint()
          ..strokeWidth = ((radius - borderWidth) / 10)
          ..strokeCap = StrokeCap.round
          ..color = centerPointColor;
    canvas.drawPoints(PointMode.points, [const Offset(0, 0)], centerPointPaint);
  }

  /// draw ticks
  void _paintTicks(
    Canvas canvas,
    double radius,
    double tickWidth,
    double bigTickWidth,
  ) {
    List<Offset> ticks = [];
    List<Offset> bigTicks = [];
    for (var i = 0; i < 60; i++) {
      double angle = i * 6.0;
      if (i % 5 != 0) {
        double x = cos(getRadians(angle)) * radius;
        double y = sin(getRadians(angle)) * radius;
        ticks.add(Offset(x, y));
      } else {
        double x = cos(getRadians(angle)) * radius;
        double y = sin(getRadians(angle)) * radius;
        bigTicks.add(Offset(x, y));
      }
    }
    Paint tickPaint =
        Paint()
          ..color = tickColor
          ..strokeWidth = tickWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.points, ticks, tickPaint);

    Paint bigTickPaint =
        Paint()
          ..color = tickColor
          ..strokeWidth = bigTickWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.points, bigTicks, bigTickPaint);
  }

  /// draw number（1 - 12）
  double _paintHourText(Canvas canvas, double radius, double fontSize) {
    double maxTextHeight = 0;
    for (var i = 0; i < 12; i++) {
      double angle = i * 30.0;
      canvas.save();
      double hourNumberX = cos(getRadians(angle)) * radius;
      double hourNumberY = sin(getRadians(angle)) * radius;
      canvas.translate(hourNumberX, hourNumberY);
      int intHour = i + 3;
      if (intHour > 12) intHour = intHour - 12;

      String hourText = hourNumbers[intHour - 1];
      _hourTextPainter.text = TextSpan(
        text: hourText,
        style: TextStyle(
          fontSize: fontSize,
          color: numberColor,
          fontWeight: FontWeight.w900,
        ),
      );
      _hourTextPainter.layout();
      if (_hourTextPainter.height > maxTextHeight) {
        maxTextHeight = _hourTextPainter.height;
      }
      _hourTextPainter.paint(
        canvas,
        Offset(-_hourTextPainter.width / 2, -_hourTextPainter.height / 2),
      );
      canvas.restore();
    }
    return maxTextHeight;
  }

  /// draw hour hand
  void _paintHourHand(Canvas canvas, double radius, double strokeWidth) {
    double angle = _dateTime.hour % 12 + _dateTime.minute / 60.0 - 3;
    Offset handOffset = Offset(
      cos(getRadians(angle * 30)) * radius,
      sin(getRadians(angle * 30)) * radius,
    );
    final hourHandPaint =
        Paint()
          ..color = hourHandColor
          ..strokeWidth = strokeWidth;
    canvas.drawLine(const Offset(0, 0), handOffset, hourHandPaint);
  }

  /// draw minute hand
  void _paintMinuteHand(Canvas canvas, double radius, double strokeWidth) {
    double angle = _dateTime.minute + _dateTime.second / 60 - 15.0;
    Offset handOffset = Offset(
      cos(getRadians(angle * 6.0)) * radius,
      sin(getRadians(angle * 6.0)) * radius,
    );
    final hourHandPaint =
        Paint()
          ..color = minuteHandColor
          ..strokeWidth = strokeWidth;
    canvas.drawLine(const Offset(0, 0), handOffset, hourHandPaint);
  }

  /// draw second hand
  void _paintSecondHand(Canvas canvas, double radius, double strokeWidth) {
    double angle = _dateTime.second - 15.0;
    Offset handOffset = Offset(
      cos(getRadians(angle * 6.0)) * radius,
      sin(getRadians(angle * 6.0)) * radius,
    );
    final hourHandPaint =
        Paint()
          ..color = secondHandColor
          ..strokeWidth = strokeWidth;
    canvas.drawLine(const Offset(0, 0), handOffset, hourHandPaint);
  }

  @override
  bool shouldRepaint(AnalogClockPainter oldDelegate) {
    return _dateTime != oldDelegate._dateTime ||
        dialPlateColor != oldDelegate.dialPlateColor ||
        hourHandColor != oldDelegate.hourHandColor ||
        minuteHandColor != oldDelegate.minuteHandColor ||
        secondHandColor != oldDelegate.secondHandColor ||
        tickColor != oldDelegate.tickColor ||
        numberColor != oldDelegate.numberColor ||
        borderColor != oldDelegate.borderColor ||
        centerPointColor != oldDelegate.centerPointColor ||
        showBorder != oldDelegate.showBorder ||
        showTicks != oldDelegate.showTicks ||
        showMinuteHand != oldDelegate.showMinuteHand ||
        showSecondHand != oldDelegate.showSecondHand ||
        showNumber != oldDelegate.showNumber ||
        hourNumbers != oldDelegate.hourNumbers ||
        _borderWidth != oldDelegate._borderWidth ||
        hourNumberScale != oldDelegate.hourNumberScale;
  }

  static double getRadians(double angle) {
    return angle * pi / 180;
  }
}
