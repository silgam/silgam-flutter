import 'package:freezed_annotation/freezed_annotation.dart';

import 'exam.dart';
import 'lap_time.dart';

part 'exam_detail.freezed.dart';

@freezed
class ExamDetail with _$ExamDetail {
  const factory ExamDetail({
    required List<Exam> exams,
    required DateTime examStartedTime,
    required DateTime examFinishedTime,
    required List<LapTime> lapTimes,
  }) = _ExamDetail;
}
