import 'package:freezed_annotation/freezed_annotation.dart';

import 'exam.dart';

part 'timetable.freezed.dart';
part 'timetable.g.dart';

@freezed
class Timetable with _$Timetable {
  const Timetable._();

  const factory Timetable({
    required String name,
    required DateTime startTime,
    required List<TimetableItem> items,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isAllSubjectsTimetable,
  }) = _Timetable;

  factory Timetable.fromJson(Map<String, dynamic> json) =>
      _$TimetableFromJson(json);

  List<Exam> get exams => items.map((e) => e.exam).toList();

  Duration get duration => items.fold(
    const Duration(),
    (previousValue, item) =>
        previousValue +
        Duration(minutes: item.exam.timetableDurationMinutes) +
        Duration(minutes: item.breakMinutesAfter),
  );

  DateTime get endTime => startTime.add(duration);

  String toExamNamesString() {
    return items.map((e) => e.exam.name).join(', ');
  }

  String toSubjectNamesString() {
    return exams.map((e) => e.subject.name).join(', ');
  }
}

@freezed
class TimetableItem with _$TimetableItem {
  const factory TimetableItem({
    @JsonKey(name: 'examId', toJson: Exam.toId, fromJson: Exam.fromId)
    required Exam exam,
    @Default(0) int breakMinutesAfter,
  }) = _TimetableItem;

  factory TimetableItem.fromJson(Map<String, dynamic> json) =>
      _$TimetableItemFromJson(json);
}
