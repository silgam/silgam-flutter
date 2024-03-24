import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

import '../../../model/exam.dart';
import '../../../model/lap_time.dart';
import '../../../model/relative_time.dart';
import '../../../model/timetable.dart';
import '../../../repository/noise/noise_repository.dart';
import '../../../util/analytics_manager.dart';
import '../../app/cubit/app_cubit.dart';
import '../../noise_setting/cubit/noise_setting_cubit.dart';
import '../breakpoint.dart';
import '../noise/noise_generator.dart';
import '../noise/noise_player.dart';

part 'clock_cubit.freezed.dart';
part 'clock_state.dart';

const _announcementsAssetPath = 'assets/announcements';

@injectable
class ClockCubit extends Cubit<ClockState> {
  ClockCubit(
    @factoryParam Timetable timetable,
    this._appCubit,
    this._noiseSettingCubit,
  ) : super(ClockState(
          currentTime: DateTime.now(),
          examStartedTime: DateTime.now(),
          pageOpenedTime: DateTime.now(),
          timetable: timetable,
        )) {
    _initialize();
  }

  final AppCubit _appCubit;
  final NoiseSettingCubit _noiseSettingCubit;

  final AudioPlayer _announcementPlayer = AudioPlayer();
  Timer? _timer;
  NoiseGenerator? _noiseGenerator;

  get defaultLogProperties => {
        'timetable_name': state.timetable.name,
        'exam_names': state.timetable.toExamNamesString(),
        'subject_names': state.timetable.toSubjectNamesString(),
      };

  void _initialize() {
    final breakpointGroups =
        BreakpointGroup.createBreakpointGroupsFromTimetable(state.timetable);

    emit(state.copyWith(
      breakpointGroups: breakpointGroups,
      currentTime: breakpointGroups.first.breakpoints.first.time,
    ));

    if (!kIsWeb && Platform.isAndroid) _announcementPlayer.setVolume(0.4);

    final nosieSettingState = _noiseSettingCubit.state;
    if (nosieSettingState.selectedNoisePreset != NoisePreset.disabled) {
      final noisePlayer = NoiseAudioPlayer(
        availableNoiseIds: _appCubit.state.productBenefit.availableNoiseIds,
      );
      _noiseGenerator = NoiseGenerator(
        noiseSettingState: nosieSettingState,
        noisePlayer: noisePlayer,
        clockCubit: this,
      );
    }
  }

  void onScreenTap() {
    emit(state.copyWith(isUiVisible: !state.isUiVisible));
  }

  void startExam() {
    emit(state.copyWith(isStarted: true));
    _timer = Timer.periodic(1.seconds, (_) {
      if (state.isRunning) {
        _onEverySecond(state.currentTime.add(1.seconds));
      }
    });
    _playAnnouncement();
    _noiseGenerator?.start();

    AnalyticsManager.eventStartTime(name: '[ClockPage] Finish exam');
    AnalyticsManager.logEvent(
      name: '[ClockPage] Start exam',
      properties: defaultLogProperties,
    );
  }

  void subtract30Seconds() {
    final announcementPosition = _announcementPlayer.position.inMilliseconds;
    final announcementDuration =
        _announcementPlayer.duration?.inMilliseconds ?? 0;
    if ((announcementPosition - announcementDuration).abs() > 100) {
      _announcementPlayer.seek(_announcementPlayer.position - 30.seconds);
    }

    final newTime = state.currentTime.subtract(30.seconds);
    _onTimeChanged(newTime);

    AnalyticsManager.logEvent(
      name: '[ClockPage] Substract 30 seconds',
      properties: {
        ...defaultLogProperties,
        'current_time': state.currentTime.toString(),
      },
    );
  }

  void add30Seconds() {
    final newTime = state.currentTime.add(30.seconds);
    _announcementPlayer.seek(_announcementPlayer.position + 30.seconds);
    _onTimeChanged(newTime);

    AnalyticsManager.logEvent(
      name: '[ClockPage] Add 30 seconds',
      properties: {
        ...defaultLogProperties,
        'current_time': state.currentTime.toString(),
      },
    );
  }

  void onBreakpointTap(int index) {
    _moveBreakpoint(index: index);
  }

  void onPausePlayButtonPressed() {
    emit(state.copyWith(isRunning: !state.isRunning));
    if (state.isRunning) {
      _announcementPlayer.play();
      _noiseGenerator?.playWhiteNoiseIfEnabled();
    } else {
      _announcementPlayer.pause();
      _noiseGenerator?.pauseWhiteNoise();
    }

    AnalyticsManager.logEvent(
      name: '[ClockPage] Play/Pause Button Pressed',
      properties: {
        ...defaultLogProperties,
        'current_time': state.currentTime.toString(),
        'running': state.isRunning,
      },
    );
  }

  void onLapTimeButtonPressed() {
    final newLapTime = LapTime(
      time: state.currentTime,
      createdAt: DateTime.now(),
    );
    if (state.lapTimes.every((e) => e.time != newLapTime.time)) {
      emit(state.copyWith(
        lapTimes: [...state.lapTimes, newLapTime],
      ));
    }

    AnalyticsManager.logEvent(
      name: '[ClockPage] Lap Time Button Pressed',
      properties: {
        ...defaultLogProperties,
        'current_time': state.currentTime.toString(),
        'lap_times': state.lapTimes.toString(),
      },
    );
  }

  void _onEverySecond(DateTime newTime) {
    emit(state.copyWith(currentTime: newTime));
    if (!state.isFinished) {
      final nextBreakpoint =
          state.breakpoints[state.currentBreakpointIndex + 1];
      if (newTime.compareTo(nextBreakpoint.time) >= 0) _moveToNextBreakpoint();
    }
  }

  void _moveToNextBreakpoint() {
    if (state.isFinished) return;
    _moveBreakpoint(index: state.currentBreakpointIndex + 1);
  }

  void _moveToPreviousBreakpoint({bool adjustTime = true}) {
    if (state.currentBreakpointIndex <= 0) return;
    _moveBreakpoint(
      index: state.currentBreakpointIndex - 1,
      adjustTime: adjustTime,
    );
  }

  void _moveBreakpoint({required int index, bool adjustTime = true}) {
    final nextExamIndex = state.breakpoints
        .take(index + 1)
        .where((breakpoint) =>
            breakpoint.announcement.time ==
            const RelativeTime.afterFinish(minutes: 0))
        .length
        .clamp(0, state.timetable.items.length - 1);

    emit(state.copyWith(
      currentBreakpointIndex: index,
      currentExamIndex: nextExamIndex,
    ));
    _saveExamStartedTimeIfNeeded();
    _saveExamFinishedTimeIfNeeded();
    _announcementPlayer.pause();
    if (adjustTime) {
      emit(state.copyWith(currentTime: state.currentBreakpoint.time));
      _playAnnouncement();
    }
  }

  Future<void> _playAnnouncement() async {
    await _announcementPlayer.pause();
    final String? currentFileName =
        state.currentBreakpoint.announcement.fileName;
    if (currentFileName == null) {
      await _announcementPlayer.seek(_announcementPlayer.duration);
      return;
    }

    await _announcementPlayer
        .setAsset('$_announcementsAssetPath/$currentFileName');
    if (state.isRunning) {
      await _announcementPlayer.play();
    }
  }

  void _saveExamStartedTimeIfNeeded() {
    final currentAnnouncementTime = state.currentBreakpoint.announcement.time;
    if (currentAnnouncementTime == const RelativeTime.afterStart(minutes: 0)) {
      emit(state.copyWith(examStartedTime: DateTime.now()));
    }
  }

  void _saveExamFinishedTimeIfNeeded() {
    final currentAnnouncementTime = state.currentBreakpoint.announcement.time;
    if (currentAnnouncementTime == const RelativeTime.afterFinish(minutes: 0)) {
      emit(state.copyWith(examFinishedTime: DateTime.now()));
    }
  }

  void _onTimeChanged(DateTime newTime) {
    emit(state.copyWith(currentTime: newTime));
    if (state.currentBreakpointIndex > 0) {
      if (newTime.compareTo(state.currentBreakpoint.time) < 0) {
        _moveToPreviousBreakpoint(adjustTime: false);
        return;
      }
    }
    if (!state.isFinished) {
      final nextBreakpoint =
          state.breakpoints[state.currentBreakpointIndex + 1];
      if (newTime.compareTo(nextBreakpoint.time) >= 0) {
        _moveToNextBreakpoint();
        return;
      }
    }
  }

  @override
  Future<void> close() {
    _announcementPlayer.stop();
    _announcementPlayer.dispose();
    _noiseGenerator?.dispose();
    _timer?.cancel();
    return super.close();
  }
}

extension on int {
  Duration get seconds => Duration(seconds: this);
}
