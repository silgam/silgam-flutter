import 'package:freezed_annotation/freezed_annotation.dart';

import '../repository/exam/exam_repository.dart';
import 'subject.dart';

part 'exam.freezed.dart';
part 'exam.g.dart';

@Freezed(
  addImplicitFinal: false,
  equal: false,
)
class Exam with _$Exam {
  const Exam._();

  factory Exam({
    required final String id,
    final String? userId,
    required final Subject subject,
    required String name,
    required final int number,
    required final DateTime startTime,
    required final int durationMinutes,
    required final int numberOfQuestions,
    required final int perfectScore,
    required final int color,
    final DateTime? createdAt,
  }) = _Exam;

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);

  factory Exam.fromId(String id) =>
      defaultExams.firstWhere((element) => element.id == id);

  static String toId(Exam exam) => exam.id;

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  DateTime get timetableStartTime =>
      startTime.subtract(Duration(minutes: subject.minutesBeforeExamStart));

  int get timetableDurationMinutes =>
      durationMinutes +
      subject.minutesBeforeExamStart +
      subject.minutesAfterExamFinish;
}
