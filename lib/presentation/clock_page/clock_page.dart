import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakelock/wakelock.dart';

import '../../model/exam.dart';
import '../../model/relative_time.dart';
import '../../repository/noise_repository.dart';
import '../../repository/user_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/android_audio_manager.dart';
import '../../util/const.dart';
import '../../util/date_time_extension.dart';
import '../../util/shared_preferences_holder.dart';
import '../common/empty_scroll_behavior.dart';
import '../edit_record_page/edit_record_page.dart';
import 'breakpoint.dart';
import 'listening_audio/listening_audio_player.dart';
import 'noise/noise_generator.dart';
import 'noise/noise_player.dart';
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
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  DateTime _examStartedTime = DateTime.now();
  final DateTime _pageStartedTime = DateTime.now();

  final AudioPlayer _announcementPlayer = AudioPlayer();
  NoiseGenerator? _noiseGenerator;
  ListeningAudioPlayer? _listeningAudioPlayer;

  final ScrollController _timelineController = ScrollController();
  late final List<GlobalKey> _timelineTileKeys;
  late final List<GlobalKey> _timelineConnectorKeys;

  static const int _defaultScreenOverlayAlpha = 220;
  int _screenOverlayAlpha = _defaultScreenOverlayAlpha;
  bool _isStarted = false;
  bool _isRunning = true;
  bool _isUiVisible = true;

  InterstitialAd? _interstitialAd;

  bool get _isFinished => _currentBreakpointIndex >= _breakpoints.length - 1;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    AndroidAudioManager.controlMediaVolume();
    if (Platform.isAndroid) _announcementPlayer.setVolume(0.4);

    _breakpoints = Breakpoint.createBreakpointsFromExam(widget.exam);
    _currentTime = _breakpoints[_currentBreakpointIndex].time;
    _timelineTileKeys =
        List.generate(_breakpoints.length, (index) => GlobalKey());
    _timelineConnectorKeys =
        List.generate(_breakpoints.length - 1, (index) => GlobalKey());

    final noiseSettings = NoiseSettings()..loadAll();
    if (noiseSettings.noisePreset != NoisePreset.disabled) {
      final noisePlayer = NoiseAudioPlayer();
      _noiseGenerator = NoiseGenerator(
        noiseSettings: noiseSettings,
        noisePlayer: noisePlayer,
        fetchClockStatus: () => ClockStatus(
          exam: widget.exam,
          currentBreakpoint: _breakpoints[_currentBreakpointIndex],
          currentTime: _currentTime,
          isRunning: _isRunning,
        ),
      );
    }

    _loadAd();
    // if (widget.exam.subject == Subject.english) {
    //   _listeningAudioPlayer = ListeningAudioPlayer(
    //     breakpoints: _breakpoints,
    //     audioSource: AudioSource.uri(Uri.parse('asset:///assets/noises/english_listening_test.mp3')),
    //     examStartPosition: const Duration(minutes: 1),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: _onScreenTap,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                UiVisibility(
                  uiVisible: _isUiVisible,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
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
                  ),
                ),
                _buildScreenOverlayIfNotStarted(),
              ],
            ),
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

    if (widget.exam.examNumber != null) {
      children.add(Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(1000)),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          '${widget.exam.examNumber}교시',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ));
      children.add(const SizedBox(height: 4));
    }

    children.add(Text(
      widget.exam.examName,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w700,
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
      final time =
          '${breakpoint.time.hour12}:${breakpoint.time.minute.toString().padLeft(2, '0')}';
      tiles.add(TimelineTile(
        key: _timelineTileKeys[index],
        onTap: () => _onBreakpointTap(index),
        time: time,
        title: breakpoint.title,
        disabled: disabled,
      ));

      // Connector
      if (index == _breakpoints.length - 1) return;
      final nextBreakpoint = _breakpoints[index + 1];
      final Duration duration = nextBreakpoint.time.difference(breakpoint.time);

      double progress = 1;
      if (disabled) {
        progress = 0;
      } else if (index == _currentBreakpointIndex) {
        progress = _currentTime.difference(breakpoint.time).inSeconds /
            duration.inSeconds;
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
    if (_isSmallHeightScreen()) {
      direction = Axis.vertical;
    }

    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _subtract30Seconds,
          icon: const Icon(Icons.replay_30),
          color: Colors.grey.shade700,
          splashRadius: 20,
        ),
        IconButton(
          onPressed: _onPausePlayButtonPressed,
          icon: _isRunning
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
          color: Colors.grey.shade700,
          splashRadius: 20,
        ),
        IconButton(
          onPressed: _add30Seconds,
          icon: const Icon(Icons.forward_30),
          color: Colors.grey.shade700,
          splashRadius: 20,
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
              '화면을 터치하면 시작합니다',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '소리를 켜면 안내방송을 들을 수 있어요!\n소음 기능을 사용할 때는 양쪽 이어폰을 모두 착용하는 것을 권장해요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                height: 1.3,
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
      _listeningAudioPlayer?.updateState(_currentTime, timeJumped: false);
      if (_isFinished) return;
      final nextBreakpoint = _breakpoints[_currentBreakpointIndex + 1];
      if (newTime.compareTo(nextBreakpoint.time) >= 0) _moveToNextBreakpoint();
    });
  }

  void _subtract30Seconds() {
    final newTime = _currentTime.subtract(const Duration(seconds: 30));
    if (_announcementPlayer.position != _announcementPlayer.duration) {
      _announcementPlayer
          .seek(_announcementPlayer.position - const Duration(seconds: 30));
    }
    _onTimeChanged(newTime);

    AnalyticsManager.logEvent(
      name: '[ClockPage] Substract 30 seconds',
      properties: {
        'exam_name': widget.exam.examName,
        'current_time': _currentTime.toString(),
      },
    );
  }

  void _add30Seconds() {
    final newTime = _currentTime.add(const Duration(seconds: 30));
    _announcementPlayer
        .seek(_announcementPlayer.position + const Duration(seconds: 30));
    _onTimeChanged(newTime);

    AnalyticsManager.logEvent(
      name: '[ClockPage] Add 30 seconds',
      properties: {
        'exam_name': widget.exam.examName,
        'current_time': _currentTime.toString(),
      },
    );
  }

  void _onPausePlayButtonPressed() {
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _announcementPlayer.play();
      _noiseGenerator?.playWhiteNoiseIfEnabled();
    } else {
      _announcementPlayer.pause();
      _noiseGenerator?.pauseWhiteNoise();
    }

    AnalyticsManager.logEvent(
      name: '[ClockPage] Play/Pause Button Pressed',
      properties: {
        'exam_name': widget.exam.examName,
        'current_time': _currentTime.toString(),
        'running': _isRunning,
      },
    );
  }

  void _onTimeChanged(DateTime newTime) {
    setState(() {
      _currentTime = newTime;
    });
    _listeningAudioPlayer?.updateState(_currentTime, timeJumped: true);
    if (_currentBreakpointIndex > 0) {
      final currentBreakpoint = _breakpoints[_currentBreakpointIndex];
      if (newTime.compareTo(currentBreakpoint.time) < 0) {
        _moveToPreviousBreakpoint(adjustTime: false);
        return;
      }
    }
    if (!_isFinished) {
      final nextBreakpoint = _breakpoints[_currentBreakpointIndex + 1];
      if (newTime.compareTo(nextBreakpoint.time) >= 0) {
        _moveToNextBreakpoint();
        return;
      }
    }
  }

  void _onCloseButtonPressed() {
    if (_isFinished) {
      _finishExam();
      return;
    }
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'finish_exam_dialog'),
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '아직 시험이 끝나지 않았어요!',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text('시험을 종료하실 건가요?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                '취소',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
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

  void _moveToPreviousBreakpoint({bool adjustTime = true}) {
    if (_currentBreakpointIndex <= 0) return;
    _currentBreakpointIndex--;
    _trySavingExamStartedTime();
    _moveBreakpoint(adjustTime: adjustTime);
  }

  void _moveToNextBreakpoint() {
    if (_isFinished) return;
    _currentBreakpointIndex++;
    _trySavingExamStartedTime();
    _moveBreakpoint();
  }

  void _onBreakpointTap(int index) {
    _currentBreakpointIndex = index;
    _trySavingExamStartedTime();
    _moveBreakpoint();
  }

  void _trySavingExamStartedTime() {
    final currentAnnouncementTime =
        _breakpoints[_currentBreakpointIndex].announcement.time;
    if (currentAnnouncementTime == const RelativeTime.afterStart(minutes: 0)) {
      _examStartedTime = DateTime.now();
    }
  }

  void _moveBreakpoint({bool adjustTime = true}) {
    _announcementPlayer.pause();
    if (adjustTime) {
      _currentTime = _breakpoints[_currentBreakpointIndex].time;
      setState(() {});
      _playAnnouncement();
    }
    _listeningAudioPlayer?.updateState(_currentTime, timeJumped: true);
    _animateTimeline();
  }

  void _animateTimeline() {
    double progressedSize = 0;
    if (_isSmallHeightScreen()) {
      for (int i = 0; i < _currentBreakpointIndex; i++) {
        progressedSize +=
            _timelineTileKeys[i].currentContext?.size?.height ?? 0;
        progressedSize +=
            _timelineConnectorKeys[i].currentContext?.size?.height ?? 0;
      }
    } else {
      for (int i = 0; i < _currentBreakpointIndex; i++) {
        progressedSize += _timelineTileKeys[i].currentContext?.size?.width ?? 0;
        progressedSize +=
            _timelineConnectorKeys[i].currentContext?.size?.width ?? 0;
      }
    }

    _timelineController.animateTo(
      progressedSize,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
    );
  }

  Future<void> _playAnnouncement() async {
    await _announcementPlayer.pause();
    final String? currentFileName =
        _breakpoints[_currentBreakpointIndex].announcement.fileName;
    if (currentFileName == null) return;
    await _announcementPlayer
        .setAsset('$_announcementsAssetPath/$currentFileName');
    if (_isRunning) {
      await _announcementPlayer.play();
    }
  }

  void _startExam() {
    _isStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRunning) {
        _onEverySecond(_currentTime.add(const Duration(seconds: 1)));
      }
    });
    _playAnnouncement();
    _noiseGenerator?.start();
    _listeningAudioPlayer?.updateState(_currentTime, timeJumped: true);

    AnalyticsManager.eventStartTime(name: '[ClockPage] Finish exam');
    AnalyticsManager.logEvent(
      name: '[ClockPage] Start exam',
      properties: {
        'exam_name': widget.exam.examName,
      },
    );
  }

  void _finishExam() {
    if (isAdsEnabled &&
        DateTime.now().difference(_pageStartedTime).inMinutes >= 10) {
      _interstitialAd?.show();
    }

    final arguments = EditRecordPageArguments(
      inputExam: widget.exam,
      examStartedTime: _examStartedTime,
    );
    Navigator.pop(context);

    final sharedPreferences = SharedPreferencesHolder.get;
    const key = PreferenceKey.showAddRecordPageAfterExamFinished;
    final showAddRecordPageAfterExamFinished =
        sharedPreferences.getBool(key) ?? true;
    if (showAddRecordPageAfterExamFinished && UserRepository().isSignedIn()) {
      Navigator.pushNamed(context, EditRecordPage.routeName,
          arguments: arguments);
    }

    AnalyticsManager.logEvent(
      name: '[ClockPage] Finish exam',
      properties: {
        'exam_name': widget.exam.examName,
        'is_exam_finished': _isFinished,
      },
    );
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
      _screenOverlayAlpha = _defaultScreenOverlayAlpha;
    });
  }

  Future<void> _loadAd() async {
    if (!isAdsEnabled) return;
    await InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, _) =>
                ad.dispose(),
          );
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  @override
  void dispose() {
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    AndroidAudioManager.controlDefaultVolume();

    _announcementPlayer.dispose();
    _noiseGenerator?.dispose();
    _listeningAudioPlayer?.dispose();
    _timer?.cancel();
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
