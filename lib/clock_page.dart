import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'analog_clock/analog_clock.dart';
import 'model/announcement.dart';
import 'model/exam.dart';
import 'model/relative_time.dart';

class ClockPage extends StatefulWidget {
  static const routeName = '/clock';
  final Exam exam;

  const ClockPage({
    Key? key,
    required this.exam,
  }) : super(key: key);

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  late final List<_Breakpoint> _breakpoints;
  late int _currentBreakpointIndex = 0;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _breakpoints = _Breakpoint.createBreakpointsFromExam(widget.exam);
    _currentTime = _breakpoints[_currentBreakpointIndex].time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  child: IconButton(
                    splashRadius: 20,
                    icon: const Icon(Icons.close),
                    onPressed: _onCloseButtonPressed,
                    color: Colors.white,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 24),
                  child: OutlinedButton(
                    child: const Text(
                      '건너뛰기',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    onPressed: _onSkipButtonPressed,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      primary: Colors.white,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          WristWatch(
            clockTime: _currentTime,
            onEverySecond: _onEverySecond,
          ),
          Flexible(child: Container()),
        ],
      ),
    );
  }

  void _onEverySecond(DateTime newTime) {
    _currentTime = newTime;
    if (_currentBreakpointIndex + 1 >= _breakpoints.length) return;
    final nextBreakpoint = _breakpoints[_currentBreakpointIndex + 1];
    if (newTime.compareTo(nextBreakpoint.time) >= 0) {
      _currentBreakpointIndex++;
    }
  }

  void _onCloseButtonPressed() {
    Navigator.pop(context);
  }

  void _onSkipButtonPressed() {
    setState(() {
      if (_currentBreakpointIndex + 1 >= _breakpoints.length) return;
      _currentBreakpointIndex++;
      final nextBreakpoint = _breakpoints[_currentBreakpointIndex];
      _currentTime = nextBreakpoint.time;
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

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

class _Breakpoint {
  final String title;
  final DateTime time;
  final Announcement? announcement;

  _Breakpoint({
    required this.title,
    required this.time,
    this.announcement,
  });

  static List<_Breakpoint> createBreakpointsFromExam(Exam exam) {
    final breakpoints = <_Breakpoint>[];

    for (var announcement in exam.announcements) {
      final int minutes = announcement.time.minutes;
      final DateTime breakpointTime;
      switch (announcement.time.type) {
        case RelativeTimeType.beforeStart:
          breakpointTime = exam.examStartTime.subtract(Duration(minutes: minutes));
          break;
        case RelativeTimeType.afterStart:
          breakpointTime = exam.examStartTime.add(Duration(minutes: minutes));
          break;
        case RelativeTimeType.afterFinish:
          breakpointTime = exam.examEndTime.add(Duration(minutes: minutes));
          break;
      }
      breakpoints.add(_Breakpoint(
        title: announcement.title,
        time: breakpointTime,
      ));
    }

    breakpoints.sort((a, b) => a.time.compareTo(b.time));
    return breakpoints;
  }
}

class ClockPageArguments {
  final Exam exam;

  ClockPageArguments(this.exam);
}
