part of 'clock_cubit.dart';

@freezed
class ClockState with _$ClockState {
  const factory ClockState({
    @Default(false) bool isStarted,
    @Default(true) bool isUiVisible,
  }) = _ClockState;
}
