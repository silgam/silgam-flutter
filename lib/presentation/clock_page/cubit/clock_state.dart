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
    @Default([]) List<Exam> exams,
    @Default(0) int currentExamIndex,
    required DateTime currentTime,
    required DateTime examStartedTime,
  }) = _ClockState;

  Breakpoint get currentBreakpoint => breakpoints[currentBreakpointIndex];
  Exam get currentExam => exams[currentExamIndex];

  bool get isFinished => currentBreakpointIndex >= breakpoints.length - 1;
}
