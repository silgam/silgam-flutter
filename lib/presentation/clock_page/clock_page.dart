import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

import '../../model/exam.dart';
import '../../repository/noise_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/android_audio_manager.dart';
import '../../util/const.dart';
import '../../util/date_time_extension.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../common/empty_scroll_behavior.dart';
import '../edit_record_page/edit_record_page.dart';
import '../noise_setting/cubit/noise_setting_cubit.dart';
import 'breakpoint.dart';
import 'cubit/clock_cubit.dart';
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
  final SharedPreferences _sharedPreferences = getIt.get();
  final AppCubit _appCubit = getIt.get();
  late final ClockCubit _cubit = getIt.get(
    param1: widget.exam,
    param2: Breakpoint.createBreakpointsFromExam(widget.exam),
  );

  final DateTime _pageStartedTime = DateTime.now();

  final AudioPlayer _announcementPlayer = AudioPlayer();
  NoiseGenerator? _noiseGenerator;

  final TransformationController _clockTransformController =
      TransformationController();
  final ScrollController _timelineController = ScrollController();
  late final List<GlobalKey> _timelineTileKeys =
      List.generate(_cubit.state.breakpoints.length, (index) => GlobalKey());
  late final List<GlobalKey> _timelineConnectorKeys = List.generate(
      _cubit.state.breakpoints.length - 1, (index) => GlobalKey());

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    AndroidAudioManager.controlMediaVolume();
    if (!kIsWeb && Platform.isAndroid) _announcementPlayer.setVolume(0.4);

    final nosieSettingState = getIt.get<NoiseSettingCubit>().state;
    if (nosieSettingState.selectedNoisePreset != NoisePreset.disabled) {
      final noisePlayer = NoiseAudioPlayer(
        availableNoiseIds:
            context.read<AppCubit>().state.productBenefit.availableNoiseIds,
      );
      _noiseGenerator = NoiseGenerator(
        noiseSettingState: nosieSettingState,
        noisePlayer: noisePlayer,
        fetchClockStatus: () => ClockStatus(
          exam: widget.exam,
          currentBreakpoint:
              _cubit.state.breakpoints[_cubit.state.currentBreakpointIndex],
          currentTime: _cubit.state.currentTime,
          isRunning: _cubit.state.isRunning,
        ),
      );
    }

    _loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: GestureDetector(
              onTap: _cubit.onScreenTap,
              onLongPress: () {
                _clockTransformController.value = Matrix4.identity();
              },
              behavior: HitTestBehavior.opaque,
              child: BlocBuilder<ClockCubit, ClockState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      InteractiveViewer(
                        transformationController: _clockTransformController,
                        minScale: 0.5,
                        boundaryMargin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width,
                          vertical: MediaQuery.of(context).size.height,
                        ),
                        child: Center(
                          child: WristWatch(
                            clockTime: state.currentTime,
                          ),
                        ),
                      ),
                      UiVisibility(
                        uiVisible: state.isUiVisible,
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
                        uiVisible: state.isUiVisible,
                        child: _buildBackgroundUi(),
                      ),
                      if (!state.isStarted) _buildScreenOverlay(),
                    ],
                  );
                },
              ),
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
    final state = _cubit.state;
    final tiles = <Widget>[];
    state.breakpoints.asMap().forEach((index, breakpoint) {
      bool disabled = false;
      if (index > state.currentBreakpointIndex) disabled = true;

      // Tile
      final time =
          '${breakpoint.time.hour12}:${breakpoint.time.minute.toString().padLeft(2, '0')}';
      tiles.add(TimelineTile(
        key: _timelineTileKeys[index],
        onTap: () => _cubit.onBreakpointTap(index),
        time: time,
        title: breakpoint.title,
        disabled: disabled,
      ));

      // Connector
      if (index == state.breakpoints.length - 1) return;
      final nextBreakpoint = state.breakpoints[index + 1];
      final Duration duration = nextBreakpoint.time.difference(breakpoint.time);

      double progress = 1;
      if (disabled) {
        progress = 0;
      } else if (index == state.currentBreakpointIndex) {
        progress = state.currentTime.difference(breakpoint.time).inSeconds /
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
          onPressed: _cubit.subtract30Seconds,
          icon: const Icon(Icons.replay_30),
          color: Colors.grey.shade700,
          splashRadius: 20,
        ),
        IconButton(
          onPressed: _cubit.onPausePlayButtonPressed,
          icon: _cubit.state.isRunning
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
          color: Colors.grey.shade700,
          splashRadius: 20,
        ),
        IconButton(
          onPressed: _cubit.add30Seconds,
          icon: const Icon(Icons.forward_30),
          color: Colors.grey.shade700,
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildScreenOverlay() {
    const int defaultScreenOverlayAlpha = 220;
    int screenOverlayAlpha = defaultScreenOverlayAlpha;
    return StatefulBuilder(
      builder: (context, setOverlayState) {
        return GestureDetector(
          onTapDown: (_) {
            setOverlayState(() {
              screenOverlayAlpha = 160;
            });
          },
          onTapUp: (_) {
            setOverlayState(() {
              screenOverlayAlpha = 0;
            });
            _cubit.startExam();
          },
          onTapCancel: () {
            setOverlayState(() {
              screenOverlayAlpha = defaultScreenOverlayAlpha;
            });
          },
          child: AnimatedContainer(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            color: Colors.black.withAlpha(screenOverlayAlpha),
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
      },
    );
  }

  void _onCloseButtonPressed() {
    if (_cubit.state.isFinished) {
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

  void _finishExam() {
    final isAdsRemoved =
        getIt.get<AppCubit>().state.productBenefit.isAdsRemoved;
    if (!isAdsRemoved &&
        DateTime.now().difference(_pageStartedTime).inMinutes >= 10) {
      _interstitialAd?.show();
    }

    final arguments = EditRecordPageArguments(
      inputExam: widget.exam,
      examStartedTime: _cubit.state.examStartedTime,
    );
    Navigator.pop(context);

    const key = PreferenceKey.showAddRecordPageAfterExamFinished;
    final showAddRecordPageAfterExamFinished =
        _sharedPreferences.getBool(key) ?? true;
    if (showAddRecordPageAfterExamFinished && _appCubit.state.isSignedIn) {
      Navigator.pushNamed(
        context,
        EditRecordPage.routeName,
        arguments: arguments,
      );
    }

    AnalyticsManager.logEvent(
      name: '[ClockPage] Finish exam',
      properties: {
        'exam_name': widget.exam.examName,
        'is_exam_finished': _cubit.state.isFinished,
      },
    );
  }

  void _animateTimeline() {
    double progressedSize = 0;
    if (_isSmallHeightScreen()) {
      for (int i = 0; i < _cubit.state.currentBreakpointIndex; i++) {
        progressedSize +=
            _timelineTileKeys[i].currentContext?.size?.height ?? 0;
        progressedSize +=
            _timelineConnectorKeys[i].currentContext?.size?.height ?? 0;
      }
    } else {
      for (int i = 0; i < _cubit.state.currentBreakpointIndex; i++) {
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
        _cubit.state.currentBreakpoint.announcement.fileName;
    if (currentFileName == null) return;
    await _announcementPlayer
        .setAsset('$_announcementsAssetPath/$currentFileName');
    if (_cubit.state.isRunning) {
      await _announcementPlayer.play();
    }
  }

  Future<bool> _onBackPressed() async {
    _onCloseButtonPressed();
    return false;
  }

  Future<void> _loadAd() async {
    final isAdsRemoved =
        getIt.get<AppCubit>().state.productBenefit.isAdsRemoved;
    if (isAdsRemoved) return;
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
