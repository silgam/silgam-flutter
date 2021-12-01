import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/exam.dart';
import '../util/date_time_extension.dart';
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
          Flexible(
            child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildTimelineTiles(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onEverySecond(DateTime newTime) {
    _currentTime = newTime;
    if (_currentBreakpointIndex + 1 >= _breakpoints.length) return;
    final nextBreakpoint = _breakpoints[_currentBreakpointIndex + 1];
    if (newTime.compareTo(nextBreakpoint.time) >= 0) _currentBreakpointIndex++;
    setState(() {});
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

  List<Widget> _buildTimelineTiles() {
    final tiles = <Widget>[];
    _breakpoints.asMap().forEach((index, breakpoint) {
      bool disabled = false;
      if (index > _currentBreakpointIndex) disabled = true;

      // Tile
      final time = '${breakpoint.time.hour12}:${breakpoint.time.minute.toString().padLeft(2, '0')}';
      tiles.add(_TimelineTile(time, breakpoint.title, disabled));

      // Connector
      if (index == _breakpoints.length - 1) return;
      final nextBreakpoint = _breakpoints[index + 1];
      final Duration duration = nextBreakpoint.time.difference(breakpoint.time);

      double progress = 1;
      if (disabled) {
        progress = 0;
      } else if (index == _currentBreakpointIndex) {
        progress = _currentTime.difference(breakpoint.time).inSeconds / duration.inSeconds;
      }

      tiles.add(_TimelineConnector(duration.inMinutes, progress));
    });
    return tiles;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

class _TimelineTile extends StatelessWidget {
  final String time;
  final String title;
  final bool disabled;

  const _TimelineTile(this.time, this.title, this.disabled, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            color: _getTimelineColor(disabled),
            fontWeight: FontWeight.w300,
            fontSize: 12,
          ),
        ),
        Column(children: _buildTitleTexts()),
      ],
    );
  }

  List<Text> _buildTitleTexts() {
    final texts = <Text>[];
    final regex = RegExp(r"\(([^)]+)\)");
    final allMatches = regex.allMatches(title);
    final defaultTextStyle = TextStyle(
      color: _getTimelineColor(disabled),
      fontWeight: FontWeight.w300,
      fontSize: 16,
    );
    final smallTextStyle = TextStyle(
      color: _getTimelineColor(disabled),
      fontWeight: FontWeight.w100,
      fontSize: 10,
    );
    if (allMatches.isEmpty) {
      texts.add(Text(title, style: defaultTextStyle));
    } else {
      final splitIndex = allMatches.last.start;
      texts.add(Text(title.substring(0, splitIndex).trim(), style: defaultTextStyle));
      texts.add(Text(title.substring(splitIndex).trim(), style: smallTextStyle));
    }
    return texts;
  }
}

class _TimelineConnector extends StatelessWidget {
  final int duration;
  final double progress;

  const _TimelineConnector(this.duration, this.progress, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 1,
        width: duration * 3.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_getTimelineColor(false), _getTimelineColor(true)],
            stops: [progress, progress],
          ),
        ),
      ),
    );
  }
}

class ClockPageArguments {
  final Exam exam;

  ClockPageArguments(this.exam);
}

Color _getTimelineColor(bool disabled) {
  if (disabled) return Colors.grey[700]!;
  return Colors.white;
}
