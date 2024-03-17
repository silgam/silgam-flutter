part of 'clock_cubit.dart';

@freezed
class ClockState with _$ClockState {
  const ClockState._();

  const factory ClockState({
    @Default(false) bool isStarted,
    @Default(true) bool isUiVisible,
    @Default(true) bool isRunning,
    @Default([]) List<BreakpointGroup> breakpointGroups,
    @Default(0) int currentBreakpointIndex,
    required Timetable timetable,
    @Default(0) int currentExamIndex,
    required DateTime currentTime,
    required DateTime examStartedTime,
    @Default(null) DateTime? examFinishedTime,
    required DateTime pageOpenedTime,
    @Default([]) List<LapTime> lapTimes,
  }) = _ClockState;

  List<Breakpoint> get breakpoints =>
      breakpointGroups.expand((e) => e.breakpoints).toList();
  Breakpoint get currentBreakpoint => breakpoints[currentBreakpointIndex];
  Exam get currentExam => timetable.items[currentExamIndex].exam;

  bool get isFinished => currentBreakpointIndex >= breakpoints.length - 1;
}
