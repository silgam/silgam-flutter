import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakelock/wakelock.dart';

import '../edit_record_page/edit_record_page.dart';
import '../model/exam.dart';
import '../model/subject.dart';
import '../util/android_audio_manager.dart';
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
    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    AndroidAudioManager.controlMediaVolume();

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
              UiVisibility(
                uiVisible: _isUiVisible,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: IconButton(
                    splashRadius: 20,
                    icon: const Icon(Icons.close),
                    onPressed: _onCloseButtonPressed,
                    color: Colors.white,
                  ),
                ),
              ),
              UiVisibility(
                uiVisible: _isUiVisible,
                child: _buildBackgroundUi(),
              ),
              Container(
                alignment: Alignment.center,
                child: WristWatch(
                  clockTime: _currentTime,
                  onEverySecond: _onEverySecond,
                  isLive: _isStarted,
                ),
              ),
              _buildScreenOverlayIfNotStarted(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundUi() {
    Axis direction = Axis.vertical;
    if (_isSmallHeightScreen()) direction = Axis.horizontal;
    return Flex(
      direction: direction,
      children: [
        Expanded(child: _buildExamTitle()),
        const WristWatchContainer(),
        Expanded(
          child: Flex(
            direction: direction,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeline(),
              _buildNavigator(),
            ],
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildTimeline() {
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 40);
    EdgeInsets margin = const EdgeInsets.only(bottom: 12);
    Axis direction = Axis.horizontal;
    if (_isSmallHeightScreen()) {
      padding = const EdgeInsets.symmetric(vertical: 40);
      margin = const EdgeInsets.only(right: 12);
      direction = Axis.vertical;
    }
    return Container(
      alignment: Alignment.center,
      margin: margin,
      child: ScrollConfiguration(
        behavior: EmptyScrollBehavior(),
        child: SingleChildScrollView(
          controller: _timelineController,
          padding: padding,
          scrollDirection: direction,
          physics: const ClampingScrollPhysics(),
          child: Flex(
            mainAxisSize: MainAxisSize.min,
            direction: direction,
            children: _buildTimelineTiles(direction),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTimelineTiles(Axis orientation) {
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
        direction: orientation,
        key: _timelineConnectorKeys[index],
      ));
    });
    return tiles;
  }

  Widget _buildNavigator() {
    Axis direction = Axis.horizontal;
    int rotate = 0;
    if (_isSmallHeightScreen()) {
      direction = Axis.vertical;
      rotate = 1;
    }

    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      children: [
        UiVisibility(
          uiVisible: _currentBreakpointIndex > 0,
          child: RotatedBox(
            quarterTurns: rotate + 2,
            child: IconButton(
              onPressed: _moveToBeforeBreakpoint,
              icon: SvgPicture.asset(
                'assets/chevron.svg',
                color: Colors.grey[700],
              ),
              splashRadius: 20,
            ),
          ),
        ),
        UiVisibility(
          uiVisible: !_isFinished,
          child: RotatedBox(
            quarterTurns: rotate,
            child: IconButton(
              onPressed: _moveToNextBreakpoint,
              icon: SvgPicture.asset(
                'assets/chevron.svg',
                color: Colors.grey[700],
              ),
              splashRadius: 20,
            ),
          ),
        ),
      ],
    );
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
    setState(() {
      _currentTime = newTime;
      if (_isFinished) return;
      final nextBreakpoint = _breakpoints[_currentBreakpointIndex + 1];
      if (newTime.compareTo(nextBreakpoint.time) >= 0) _moveToNextBreakpoint();
    });
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
                _finishExam();
              },
              child: const Text('시험 종료'),
            ),
          ],
        );
      },
    );
  }

  void _moveToBeforeBreakpoint() {
    if (_currentBreakpointIndex <= 0) return;
    _currentBreakpointIndex--;
    _moveBreakpoint();
  }

  void _moveToNextBreakpoint() {
    if (_isFinished) return;
    _currentBreakpointIndex++;
    _moveBreakpoint();
  }

  void _moveBreakpoint() {
    player.pause();
    setState(() {
      _currentTime = _breakpoints[_currentBreakpointIndex].time;
    });
    _animateTimeline();
    _playAnnouncement();
  }

  void _animateTimeline() {
    double progressedSize = 0;
    if (_isSmallHeightScreen()) {
      for (int i = 0; i < _currentBreakpointIndex; i++) {
        progressedSize += _timelineTileKeys[i].currentContext?.size?.height ?? 0;
        progressedSize += _timelineConnectorKeys[i].currentContext?.size?.height ?? 0;
      }
    } else {
      for (int i = 0; i < _currentBreakpointIndex; i++) {
        progressedSize += _timelineTileKeys[i].currentContext?.size?.width ?? 0;
        progressedSize += _timelineConnectorKeys[i].currentContext?.size?.width ?? 0;
      }
    }

    _timelineController.animateTo(
      progressedSize,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
    );
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

  void _finishExam() {
    Navigator.pop(context);
    final arguments = EditRecordPageArguments();
    Navigator.pushNamed(context, EditRecordPage.routeName, arguments: arguments);
  }

  Future<bool> _onBackPressed() {
    _onCloseButtonPressed();
    return Future.value(false);
  }

  void _onScreenTap() {
    setState(() {
      _isUiVisible = !_isUiVisible;
    });
  }

  void _onOverlayTapDown(TapDownDetails tapDownDetails) {
    setState(() {
      _screenOverlayAlpha = 160;
    });
  }

  void _onOverlayTapUp(TapUpDetails tapUpDetails) {
    setState(() {
      _screenOverlayAlpha = 0;
      _startExam();
    });
  }

  void _onOverlayTapCancel() {
    setState(() {
      _screenOverlayAlpha = defaultScreenOverlayAlpha;
    });
  }

  @override
  void dispose() {
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    AndroidAudioManager.controlDefaultVolume();

    player.dispose();
    super.dispose();
  }

  bool _isSmallHeightScreen() {
    return MediaQuery.of(context).size.height < 600;
  }
}

class ClockPageArguments {
  final Exam exam;

  ClockPageArguments(this.exam);
}
