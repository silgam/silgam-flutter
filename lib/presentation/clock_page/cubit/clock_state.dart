part of 'clock_cubit.dart';

@freezed
class ClockState with _$ClockState {
  const ClockState._();

  const factory ClockState({
    @Default(false) bool isStarted,
    @Default(true) bool isUiVisible,
    @Default(true) bool isRunning,
    required List<Breakpoint> breakpoints,
    required int currentBreakpointIndex,
    required DateTime currentTime,
    required DateTime examStartedTime,
  }) = _ClockState;

  Breakpoint get currentBreakpoint => breakpoints[currentBreakpointIndex];

  bool get isFinished => currentBreakpointIndex >= breakpoints.length - 1;
}
