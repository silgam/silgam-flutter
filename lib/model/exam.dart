import 'package:freezed_annotation/freezed_annotation.dart';

import '../repository/exam/exam_repository.dart';
import '../util/date_time_extension.dart';
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
    required final Subject subject,
    required String name,
    required final int number,
    required final DateTime startTime,
    required final int durationMinutes,
    required final int numberOfQuestions,
    required final int perfectScore,
    required final int color,
  }) = _Exam;

  String get id => subject.name;

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);

  factory Exam.fromId(String id) =>
      defaultExams.firstWhere((element) => element.id == id);

  static String toId(Exam exam) => exam.id;

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  String getPeriodString() {
    final startHour = '${startTime.hour12}시 ';
    final String startMinute;
    if (startTime.minute == 0) {
      startMinute = '';
    } else {
      startMinute = '${startTime.minute}분 ';
    }

    final endHour = '${endTime.hour12}시 ';
    final String endMinute;
    if (endTime.minute == 0) {
      endMinute = '';
    } else {
      endMinute = '${endTime.minute}분 ';
    }

    return '$startHour$startMinute~ $endHour$endMinute';
  }
}

extension ExamListExtension on List<Exam> {
  String toExamNamesString() {
    return map((e) => e.name).join(', ');
  }
}
