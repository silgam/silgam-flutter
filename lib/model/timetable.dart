import 'package:freezed_annotation/freezed_annotation.dart';

import 'exam.dart';

part 'timetable.freezed.dart';
part 'timetable.g.dart';

@freezed
class Timetable with _$Timetable {
  const factory Timetable({
    required final DateTime startTime,
    required List<TimetableItem> items,
  }) = _Timetable;

  factory Timetable.fromJson(Map<String, dynamic> json) =>
      _$TimetableFromJson(json);
}

@freezed
class TimetableItem with _$TimetableItem {
  const factory TimetableItem({
    @JsonKey(name: 'examId', toJson: Exam.toJson) required Exam exam,
    required int breakMinutesAfter,
  }) = _TimetableItem;

  factory TimetableItem.fromJson(Map<String, dynamic> json) =>
      _$TimetableItemFromJson(json);
}
