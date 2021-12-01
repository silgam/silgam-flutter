import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/exam.dart';
import '../util/date_time_extension.dart';
import '../util/empty_scroll_behavior.dart';
import 'breakpoint.dart';
import 'timeline.dart';
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

  static const int defaultScreenOverlayAlpha = 220;
  int _screenOverlayAlpha = defaultScreenOverlayAlpha;
  bool _isStarted = false;

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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTopMenu(),
                    Expanded(child: _buildExamTitle()),
                  ],
                ),
              ),
              WristWatch(
                clockTime: _currentTime,
                onEverySecond: _onEverySecond,
                isLive: _isStarted,
              ),
              Expanded(
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
          _buildScreenOverlayIfNotStarted(),
        ],
      ),
    );
  }

  void _onEverySecond(DateTime newTime) {
    _currentTime = newTime;
    if (_currentBreakpointIndex + 1 >= _breakpoints.length) return;
    final nextBreakpoint = _breakpoints[_currentBreakpointIndex + 1];
    if (newTime.compareTo(nextBreakpoint.time) >= 0) _moveToNextBreakpoint();
    setState(() {});
  }

  void _onCloseButtonPressed() {
    Navigator.pop(context);
  }

  void _onSkipButtonPressed() {
    setState(() {
      if (_currentBreakpointIndex + 1 >= _breakpoints.length) return;
      _moveToNextBreakpoint();
      _currentTime = _breakpoints[_currentBreakpointIndex].time;
    });
  }

  void _moveToNextBreakpoint() {
    _currentBreakpointIndex++;
    double progressedWidth = 0;
    for (int i = 0; i < _currentBreakpointIndex; i++) {
      progressedWidth += _timelineTileKeys[i].currentContext?.size?.width ?? 0;
      progressedWidth += _timelineConnectorKeys[i].currentContext?.size?.width ?? 0;
    }
    _timelineController.animateTo(
      progressedWidth,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
    );
  }

  Widget _buildTopMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }

  Widget _buildExamTitle() {
    final children = <Widget>[];

    if (widget.exam.subjectNumber != null) {
      children.add(Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(1000)),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          '${widget.exam.subjectNumber}교시',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ));
    }

    children.add(Text(
      widget.exam.subjectName,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
    ));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _buildScreenOverlayIfNotStarted() {
    if (_isStarted == true) return const SizedBox.shrink();
    return GestureDetector(
      onTapDown: _onScreenTapDown,
      onTapUp: _onScreenTapUp,
      onTapCancel: _onScreenTapCancel,
      child: AnimatedContainer(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        color: Colors.black.withAlpha(_screenOverlayAlpha),
        duration: const Duration(milliseconds: 100),
        child: const Text(
          '화면을 터치하면 시작됩니다',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _onScreenTapDown(TapDownDetails tapDownDetails) {
    _screenOverlayAlpha = 160;
    setState(() {});
  }

  void _onScreenTapUp(TapUpDetails tapUpDetails) {
    _screenOverlayAlpha = 0;
    _isStarted = true;
    setState(() {});
  }

  void _onScreenTapCancel() {
    _screenOverlayAlpha = defaultScreenOverlayAlpha;
    setState(() {});
  }

  List<Widget> _buildTimelineTiles() {
    final tiles = <Widget>[];
    _breakpoints.asMap().forEach((index, breakpoint) {
      bool disabled = false;
      if (index > _currentBreakpointIndex) disabled = true;

      // Tile
      final time = '${breakpoint.time.hour12}:${breakpoint.time.minute.toString().padLeft(2, '0')}';
      tiles.add(TimelineTile(
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

      tiles.add(TimelineConnector(
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

class ClockPageArguments {
  final Exam exam;

  ClockPageArguments(this.exam);
}
