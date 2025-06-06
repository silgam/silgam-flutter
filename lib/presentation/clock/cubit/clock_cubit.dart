import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/announcement.dart';
import '../../../model/exam.dart';
import '../../../model/lap_time.dart';
import '../../../model/timetable.dart';
import '../../../repository/noise/noise_repository.dart';
import '../../../util/analytics_manager.dart';
import '../../../util/announcement_player.dart';
import '../../app/cubit/app_cubit.dart';
import '../../noise_setting/cubit/noise_setting_cubit.dart';
import '../breakpoint.dart';
import '../noise/noise_generator.dart';
import '../noise/noise_player.dart';

part 'clock_cubit.freezed.dart';
part 'clock_state.dart';

@injectable
class ClockCubit extends Cubit<ClockState> {
  ClockCubit(
    @factoryParam this._timetable,
    this._appCubit,
    this._noiseSettingCubit,
    this._announcementPlayer,
  ) : super(
        ClockState(
          currentTime: DateTime.now(),
          pageOpenedTime: DateTime.now(),
          timetableStartedTime: DateTime.now(),
        ),
      ) {
    _initialize();
  }

  final Timetable _timetable;
  final AppCubit _appCubit;
  final NoiseSettingCubit _noiseSettingCubit;
  final AnnouncementPlayer _announcementPlayer;

  Timer? _timer;
  NoiseGenerator? _noiseGenerator;

  get defaultLogProperties => {
    'timetable_name': _timetable.name,
    'exam_names': _timetable.toExamNamesString(),
    'subject_names': _timetable.toSubjectNamesString(),
    'is_exam_finished': state.isFinished,
    'exam_ids': _timetable.items.map((item) => item.exam.id).join(', '),
    'isCustomExams': _timetable.items.map((item) => item.exam.isCustomExam).join(', '),
  };

  void _initialize() {
    final breakpoints = Breakpoint.createBreakpointsFromTimetable(_timetable);

    emit(
      state.copyWith(
        breakpoints: Breakpoint.createBreakpointsFromTimetable(_timetable),
        currentTime: breakpoints.first.time,
      ),
    );

    final noiseSettingState = _noiseSettingCubit.state;
    if (noiseSettingState.selectedNoisePreset != NoisePreset.disabled) {
      final availableNoiseIds = _appCubit.state.productBenefit.availableNoiseIds;
      final Map<int, int> availableNoiseLevels = {
        for (final MapEntry(key: id, value: level) in noiseSettingState.noiseLevels.entries)
          if (level > 0 && availableNoiseIds.contains(id)) id: level,
      };

      _noiseGenerator = NoiseGenerator(
        noisePlayer: NoiseAudioPlayer(),
        getClockState: () => state,
        useWhiteNoise: noiseSettingState.useWhiteNoise,
        noiseLevels: availableNoiseLevels,
      );
    }
  }

  void onScreenTap() {
    emit(state.copyWith(isUiVisible: !state.isUiVisible));
  }

  void startExam() {
    emit(state.copyWith(isStarted: true, timetableStartedTime: DateTime.now()));
    _restartTimer();
    _playAnnouncement();
    _noiseGenerator?.start();

    AnalyticsManager.eventStartTime(name: '[ClockPage] Finish exam');
    AnalyticsManager.logEvent(name: '[ClockPage] Start exam', properties: defaultLogProperties);
  }

  void subtract30Seconds() {
    final announcementPosition = _announcementPlayer.position.inMilliseconds;
    final announcementDuration = _announcementPlayer.duration?.inMilliseconds ?? 0;
    if ((announcementPosition - announcementDuration).abs() > 100) {
      _announcementPlayer.seek(_announcementPlayer.position - 30.seconds);
    }

    final newTime = state.currentTime.subtract(30.seconds);
    _onTimeChanged(newTime);
  }

  void add30Seconds() {
    final newTime = state.currentTime.add(30.seconds);
    _announcementPlayer.seek(_announcementPlayer.position + 30.seconds);
    _onTimeChanged(newTime);
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
  }

  void onLapTimeButtonPressed() {
    final newLapTime = LapTime(time: state.currentTime, breakpoint: state.currentBreakpoint);
    if (state.lapTimes.lastOrNull?.time != newLapTime.time) {
      emit(state.copyWith(lapTimes: [...state.lapTimes, newLapTime]));
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
      final nextBreakpoint = state.breakpoints[state.currentBreakpointIndex + 1];
      if (newTime.compareTo(nextBreakpoint.time) >= 0) _moveToNextBreakpoint();
    }
  }

  void _moveToNextBreakpoint() {
    if (state.isFinished) return;
    _moveBreakpoint(index: state.currentBreakpointIndex + 1);
  }

  void _moveToPreviousBreakpoint({bool adjustTime = true}) {
    if (state.currentBreakpointIndex <= 0) return;
    _moveBreakpoint(index: state.currentBreakpointIndex - 1, adjustTime: adjustTime);
  }

  void _moveBreakpoint({required int index, bool adjustTime = true}) {
    emit(state.copyWith(currentBreakpointIndex: index));
    _saveExamStartedTimeIfNeeded();
    _saveExamFinishedTimeIfNeeded();
    _announcementPlayer.pause();
    if (adjustTime) {
      _restartTimer();
      emit(state.copyWith(currentTime: state.currentBreakpoint.time));
      _playAnnouncement();
    }
  }

  Future<void> _playAnnouncement() async {
    await _announcementPlayer.pause();
    final String? currentFileName = state.currentBreakpoint.announcement.fileName;
    if (currentFileName == null) {
      await _announcementPlayer.seek(_announcementPlayer.duration);
      return;
    }

    await _announcementPlayer.setAnnouncement(currentFileName);
    if (state.isRunning) {
      await _announcementPlayer.play();
    }
  }

  void _saveExamStartedTimeIfNeeded() {
    if (state.currentBreakpoint.announcement.purpose == AnnouncementPurpose.start) {
      emit(
        state.copyWith(
          examStartedTimes: {...state.examStartedTimes, state.currentExam: DateTime.now()},
        ),
      );
    }
  }

  void _saveExamFinishedTimeIfNeeded() {
    if (state.currentBreakpoint.announcement.purpose == AnnouncementPurpose.finish) {
      emit(
        state.copyWith(
          examFinishedTimes: {...state.examFinishedTimes, state.currentExam: DateTime.now()},
        ),
      );
    }

    if (state.isFinished) {
      emit(state.copyWith(timetableFinishedTime: DateTime.now()));
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
      final nextBreakpoint = state.breakpoints[state.currentBreakpointIndex + 1];
      if (newTime.compareTo(nextBreakpoint.time) >= 0) {
        _moveToNextBreakpoint();
        return;
      }
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(1.seconds, (_) {
      if (state.isRunning) {
        _onEverySecond(state.currentTime.add(1.seconds));
      }
    });
  }

  @override
  Future<void> close() async {
    _timer?.cancel();

    await _announcementPlayer.stop();
    await _announcementPlayer.dispose();
    await _noiseGenerator?.dispose();

    return super.close();
  }
}

extension on int {
  Duration get seconds => Duration(seconds: this);
}
