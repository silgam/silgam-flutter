import 'package:freezed_annotation/freezed_annotation.dart';

import '../repository/exam/exam_repository.dart';
import '../util/date_time_extension.dart';
import 'subject.dart';

part 'exam.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class Exam with _$Exam {
  const Exam._();

  const factory Exam({
    required Subject subject,
    required String name,
    required int number,
    required DateTime startTime,
    required int durationMinutes,
    required int numberOfQuestions,
    required int perfectScore,
    required int color,
  }) = _Exam;

  factory Exam.fromJson(String id) =>
      defaultExams.firstWhere((element) => element.id == id);

  static String toJson(Exam exam) => exam.id;

  String get id => subject.name;

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
