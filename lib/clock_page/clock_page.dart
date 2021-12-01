import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/exam.dart';
import '../util/date_time_extension.dart';
import '../util/empty_scroll_behavior.dart';
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

  final ScrollController _timelineController = ScrollController();
  late final List<GlobalKey> _timelineTileKeys;
  late final List<GlobalKey> _timelineConnectorKeys;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _breakpoints = Breakpoint.createBreakpointsFromExam(widget.exam);
    _currentTime = _breakpoints[_currentBreakpointIndex].time;
    _timelineTileKeys = List.generate(_breakpoints.length, (index) => GlobalKey());
    _timelineConnectorKeys = List.generate(_breakpoints.length - 1, (index) => GlobalKey());
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
              child: ScrollConfiguration(
                behavior: EmptyScrollBehavior(),
                child: SingleChildScrollView(
                  controller: _timelineController,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildTimelineTiles(),
                  ),
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
    if (newTime.compareTo(nextBreakpoint.time) >= 0) moveToNextBreakpoint();
    setState(() {});
  }

  void _onCloseButtonPressed() {
    Navigator.pop(context);
  }

  void _onSkipButtonPressed() {
    setState(() {
      if (_currentBreakpointIndex + 1 >= _breakpoints.length) return;
      moveToNextBreakpoint();
      _currentTime = _breakpoints[_currentBreakpointIndex].time;
    });
  }

  void moveToNextBreakpoint() {
    _currentBreakpointIndex++;
    double progressedWidth = 0;
    for (int i = 0; i < _currentBreakpointIndex; i++) {
      progressedWidth += _timelineTileKeys[i].currentContext?.size?.width ?? 0;
      progressedWidth += _timelineConnectorKeys[i].currentContext?.size?.width ?? 0;
    }
    _timelineController.animateTo(
      progressedWidth,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  List<Widget> _buildTimelineTiles() {
    final tiles = <Widget>[];
    _breakpoints.asMap().forEach((index, breakpoint) {
      bool disabled = false;
      if (index > _currentBreakpointIndex) disabled = true;

      // Tile
      final time = '${breakpoint.time.hour12}:${breakpoint.time.minute.toString().padLeft(2, '0')}';
      tiles.add(_TimelineTile(
        time,
        breakpoint.title,
        disabled,
        key: _timelineTileKeys[index],
      ));

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

      tiles.add(_TimelineConnector(
        duration.inMinutes,
        progress,
        key: _timelineConnectorKeys[index],
      ));
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
