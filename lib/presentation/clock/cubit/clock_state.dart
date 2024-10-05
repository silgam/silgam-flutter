part of 'clock_cubit.dart';

@freezed
class ClockState with _$ClockState {
  const ClockState._();

  const factory ClockState({
    @Default(false) bool isStarted,
    @Default(true) bool isUiVisible,
    @Default(true) bool isRunning,
    @Default([]) List<Breakpoint> breakpoints,
    @Default(0) int currentBreakpointIndex,
    required DateTime currentTime,
    @Default({}) Map<Exam, DateTime> examStartedTimes,
    @Default({}) Map<Exam, DateTime> examFinishedTimes,
    @Default([]) List<LapTime> lapTimes,
    required DateTime pageOpenedTime,
    required DateTime timetableStartedTime,
    DateTime? timetableFinishedTime,
  }) = _ClockState;

  Breakpoint get currentBreakpoint => breakpoints[currentBreakpointIndex];
  Exam get currentExam => currentBreakpoint.exam;

  bool get isFinished => currentBreakpointIndex >= breakpoints.length - 1;
}
