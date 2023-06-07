import 'package:freezed_annotation/freezed_annotation.dart';

part 'lap_time.freezed.dart';

@freezed
class LapTime with _$LapTime {
  const factory LapTime({
    required DateTime time,
    required DateTime createdAt,
  }) = _LapTime;
}

@freezed
class LapTimeItem with _$LapTimeItem {
  const factory LapTimeItem({
    required DateTime time,
    required Duration timeDifference,
    required Duration timeElapsed,
  }) = _LapTimeItem;
}

@freezed
class LapTimeItemGroup with _$LapTimeItemGroup {
  const factory LapTimeItemGroup({
    required String title,
    required DateTime startTime,
    required List<LapTimeItem> lapTimeItems,
  }) = _LapTimeItemGroup;
}
