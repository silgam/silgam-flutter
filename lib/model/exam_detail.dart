import 'package:freezed_annotation/freezed_annotation.dart';

import 'exam.dart';
import 'lap_time.dart';

part 'exam_detail.freezed.dart';

@freezed
class ExamDetail with _$ExamDetail {
  const factory ExamDetail({
    required List<Exam> exams,
    required Map<Exam, DateTime> examStartedTimes,
    required Map<Exam, DateTime> examFinishedTimes,
    required List<LapTime> lapTimes,
    required DateTime timetableStartedTime,
    required DateTime timetableFinishedTime,
  }) = _ExamDetail;
}
