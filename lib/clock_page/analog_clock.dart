import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'analog_clock_painter.dart';

/// A analog clock.
class AnalogClock extends StatefulWidget {
  final DateTime dateTime;
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
  final bool isLive;
  final double width;
  final double height;
  final BoxDecoration decoration;
  final Widget? child;
  final Function(DateTime)? onEverySecond;

  const AnalogClock({
    required this.dateTime,
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
    this.isLive = true,
    this.width = double.infinity,
    this.height = double.infinity,
    this.decoration = const BoxDecoration(),
    this.child,
    this.onEverySecond,
    Key? key,
  }) : super(key: key);

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  Timer? _timer;
  DateTime? _initialDateTime;
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _updateInitialDateTimeIfChanged();
    _timer = widget.isLive
        ? Timer.periodic(const Duration(seconds: 1), (Timer timer) {
            _dateTime = _dateTime.add(const Duration(seconds: 1));
            if (mounted) setState(() {});
            widget.onEverySecond?.call(_dateTime);
          })
        : null;
  }

  @override
  Widget build(BuildContext context) {
    _updateInitialDateTimeIfChanged();
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: widget.decoration,
      child: CustomPaint(
        child: widget.child,
        painter: AnalogClockPainter(
          _dateTime,
          dialPlateColor: widget.dialPlateColor,
          hourHandColor: widget.hourHandColor,
          minuteHandColor: widget.minuteHandColor,
          secondHandColor: widget.secondHandColor,
          numberColor: widget.numberColor,
          borderColor: widget.borderColor,
          tickColor: widget.tickColor,
          centerPointColor: widget.centerPointColor,
          showBorder: widget.showBorder,
          showTicks: widget.showTicks,
          showMinuteHand: widget.showMinuteHand,
          showSecondHand: widget.showSecondHand,
          showNumber: widget.showNumber,
          borderWidth: widget.borderWidth,
          hourNumberScale: widget.hourNumberScale,
          hourNumbers: widget.hourNumbers,
        ),
      ),
    );
  }

  void _updateInitialDateTimeIfChanged() {
    if (_initialDateTime != widget.dateTime) {
      _initialDateTime = widget.dateTime;
      _dateTime = widget.dateTime;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}