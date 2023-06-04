import 'package:freezed_annotation/freezed_annotation.dart';

part 'lap_time.freezed.dart';

@freezed
class LapTime with _$LapTime {
  const factory LapTime({
    required DateTime time,
  }) = _LapTime;
}
