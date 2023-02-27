import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/exam.dart';
import '../../../model/relative_time.dart';
import '../../../util/analytics_manager.dart';
import '../breakpoint.dart';

part 'clock_cubit.freezed.dart';
part 'clock_state.dart';

@injectable
class ClockCubit extends Cubit<ClockState> {
  ClockCubit(
    @factoryParam this._exam,
    @factoryParam List<Breakpoint> breakpoints,
  ) : super(ClockState(
          breakpoints: breakpoints,
          currentBreakpointIndex: 0,
          currentTime: breakpoints[0].time,
          examStartedTime: DateTime.now(),
        ));

  final Exam _exam;
  Timer? _timer;

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
    // _playAnnouncement();
    // _noiseGenerator?.start();

    AnalyticsManager.eventStartTime(name: '[ClockPage] Finish exam');
    AnalyticsManager.logEvent(
      name: '[ClockPage] Start exam',
      properties: {
        'exam_name': _exam.examName,
      },
    );
  }

  void subtract30Seconds() {
    // final announcementPosition = _announcementPlayer.position.inMilliseconds;
    // final announcementDuration =
    //     _announcementPlayer.duration?.inMilliseconds ?? 0;
    // if ((announcementPosition - announcementDuration).abs() > 100) {
    //   _announcementPlayer.seek(_announcementPlayer.position - 30.seconds);
    // }

    final newTime = state.currentTime.subtract(30.seconds);
    _onTimeChanged(newTime);

    AnalyticsManager.logEvent(
      name: '[ClockPage] Substract 30 seconds',
      properties: {
        'exam_name': _exam.examName,
        'current_time': state.currentTime.toString(),
      },
    );
  }

  void add30Seconds() {
    final newTime = state.currentTime.add(30.seconds);
    // _announcementPlayer.seek(_announcementPlayer.position + 30.seconds);
    _onTimeChanged(newTime);

    AnalyticsManager.logEvent(
      name: '[ClockPage] Add 30 seconds',
      properties: {
        'exam_name': _exam.examName,
        'current_time': state.currentTime.toString(),
      },
    );
  }

  void onBreakpointTap(int index) {
    emit(state.copyWith(currentBreakpointIndex: index));
    _saveExamStartedTimeIfNeeded();
    _moveBreakpoint();
  }

  void onPausePlayButtonPressed() {
    emit(state.copyWith(isRunning: !state.isRunning));
    if (state.isRunning) {
      // _announcementPlayer.play();
      // _noiseGenerator?.playWhiteNoiseIfEnabled();
    } else {
      // _announcementPlayer.pause();
      // _noiseGenerator?.pauseWhiteNoise();
    }

    AnalyticsManager.logEvent(
      name: '[ClockPage] Play/Pause Button Pressed',
      properties: {
        'exam_name': _exam.examName,
        'current_time': state.currentTime.toString(),
        'running': state.isRunning,
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
    emit(state.copyWith(
      currentBreakpointIndex: state.currentBreakpointIndex + 1,
    ));
    _saveExamStartedTimeIfNeeded();
    _moveBreakpoint();
  }

  void _moveToPreviousBreakpoint({bool adjustTime = true}) {
    if (state.currentBreakpointIndex <= 0) return;
    emit(state.copyWith(
      currentBreakpointIndex: state.currentBreakpointIndex - 1,
    ));
    _saveExamStartedTimeIfNeeded();
    _moveBreakpoint(adjustTime: adjustTime);
  }

  void _moveBreakpoint({bool adjustTime = true}) {
    // _announcementPlayer.pause();
    if (adjustTime) {
      emit(state.copyWith(currentTime: state.currentBreakpoint.time));
      // _playAnnouncement();
    }
    // _animateTimeline();
  }

  void _saveExamStartedTimeIfNeeded() {
    final currentAnnouncementTime = state.currentBreakpoint.announcement.time;
    if (currentAnnouncementTime == const RelativeTime.afterStart(minutes: 0)) {
      emit(state.copyWith(examStartedTime: DateTime.now()));
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
    _timer?.cancel();
    return super.close();
  }
}

extension on int {
  Duration get seconds => Duration(seconds: this);
}
