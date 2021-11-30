import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/exam.dart';
import 'breakpoint.dart';
import 'wrist_watch.dart';

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
  late final List<Breakpoint> _breakpoints;
  late int _currentBreakpointIndex = 0;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _breakpoints = Breakpoint.createBreakpointsFromExam(widget.exam);
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

class ClockPageArguments {
  final Exam exam;

  ClockPageArguments(this.exam);
}
