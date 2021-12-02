import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../model/exam.dart';
import '../model/subject.dart';
import '../util/date_time_extension.dart';
import '../util/empty_scroll_behavior.dart';
import 'breakpoint.dart';
import 'timeline.dart';
import 'ui_visibility.dart';
import 'wrist_watch.dart';

const _announcementsAssetPath = 'assets/announcements';

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

  final AudioPlayer player = AudioPlayer();

  final ScrollController _timelineController = ScrollController();
  late final List<GlobalKey> _timelineTileKeys;
  late final List<GlobalKey> _timelineConnectorKeys;

  static const int defaultScreenOverlayAlpha = 220;
  int _screenOverlayAlpha = defaultScreenOverlayAlpha;
  bool _isStarted = false;
  bool _isUiVisible = true;

  bool get _isFinished => _currentBreakpointIndex >= _breakpoints.length - 1;

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
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _onScreenTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              _buildMainBody(),
              _buildScreenOverlayIfNotStarted(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainBody() {
    return Column(
      children: [
        Expanded(
          child: UiVisibility(
            uiVisible: _isUiVisible,
            child: _buildTopUi(),
          ),
        ),
        WristWatch(
          clockTime: _currentTime,
          onEverySecond: _onEverySecond,
          isLive: _isStarted,
        ),
        Expanded(
          child: UiVisibility(
            uiVisible: _isUiVisible,
            child: _buildBottomUi(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopUi() {
    return Column(
      children: [
        _buildTopMenu(),
        Expanded(child: _buildExamTitle()),
      ],
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
            child: Text(
              _isFinished ? '시험 종료' : '건너뛰기',
              style: const TextStyle(color: Colors.white, fontSize: 12),
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

    if (widget.exam.subject.number != null) {
      children.add(Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(1000)),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          '${widget.exam.subject.number}교시',
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
      widget.exam.subject.name,
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

  Widget _buildBottomUi() {
    return Container(
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
    );
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

  Widget _buildScreenOverlayIfNotStarted() {
    if (_isStarted == true) return const SizedBox.shrink();
    return GestureDetector(
      onTapDown: _onOverlayTapDown,
      onTapUp: _onOverlayTapUp,
      onTapCancel: _onOverlayTapCancel,
      child: AnimatedContainer(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        color: Colors.black.withAlpha(_screenOverlayAlpha),
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '화면을 터치하면 시작됩니다',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              '소리를 켜면 안내방송을 들을 수 있어요!',
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onEverySecond(DateTime newTime) {
    _currentTime = newTime;
    if (_isFinished) return;
    final nextBreakpoint = _breakpoints[_currentBreakpointIndex + 1];
    if (newTime.compareTo(nextBreakpoint.time) >= 0) _moveToNextBreakpoint();
    setState(() {});
  }

  void _onCloseButtonPressed() async {
    if (_isFinished) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('아직 시험이 끝나지 않았어요!'),
          content: const Text('시험을 종료하실 건가요?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('시험 종료'),
            ),
          ],
        );
      },
    );
  }

  void _onSkipButtonPressed() {
    if (_isFinished) {
      _onCloseButtonPressed();
      return;
    }
    player.pause();
    setState(() {
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

    _playAnnouncement();
  }

  Future<void> _playAnnouncement() async {
    await player.pause();
    final String? currentFileName = _breakpoints[_currentBreakpointIndex].announcement?.fileName;
    if (currentFileName == null) return;
    await player.setAsset('$_announcementsAssetPath/$currentFileName');
    await player.play();
  }

  void _startExam() {
    _isStarted = true;
    _playAnnouncement();
  }

  Future<bool> _onBackPressed() {
    _onCloseButtonPressed();
    return Future.value(false);
  }

  void _onScreenTap() {
    _isUiVisible = !_isUiVisible;
    setState(() {});
  }

  void _onOverlayTapDown(TapDownDetails tapDownDetails) {
    _screenOverlayAlpha = 160;
    setState(() {});
  }

  void _onOverlayTapUp(TapUpDetails tapUpDetails) {
    _screenOverlayAlpha = 0;
    _startExam();
    setState(() {});
  }

  void _onOverlayTapCancel() {
    _screenOverlayAlpha = defaultScreenOverlayAlpha;
    setState(() {});
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    player.dispose();
    super.dispose();
  }
}

class ClockPageArguments {
  final Exam exam;

  ClockPageArguments(this.exam);
}
