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
    required String examName,
    required int examNumber,
    required DateTime examStartTime,
    required int examDuration,
    required int numberOfQuestions,
    required int perfectScore,
    required int color,
  }) = _Exam;

  factory Exam.fromJson(String id) =>
      defaultExams.firstWhere((element) => element.id == id);

  static String toJson(Exam exam) => exam.id;

  String get id => subject.name;

  DateTime get examEndTime =>
      examStartTime.add(Duration(minutes: examDuration));

  String getExamTimeString() {
    final examEndTime = examStartTime.add(Duration(minutes: examDuration));
    final startHour = '${examStartTime.hour12}시 ';
    final String startMinute;
    if (examStartTime.minute == 0) {
      startMinute = '';
    } else {
      startMinute = '${examStartTime.minute}분 ';
    }

    final endHour = '${examEndTime.hour12}시 ';
    final String endMinute;
    if (examEndTime.minute == 0) {
      endMinute = '';
    } else {
      endMinute = '${examEndTime.minute}분 ';
    }

    return '$startHour$startMinute~ $endHour$endMinute';
  }
}

extension ExamListExtension on List<Exam> {
  String toExamNamesString() {
    return map((e) => e.examName).join(', ');
  }
}
