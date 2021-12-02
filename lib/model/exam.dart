import '../util/date_time_extension.dart';
import 'announcement.dart';
import 'subject.dart';

class Exam {
  final Subject subject;
  final DateTime examStartTime;
  final DateTime examEndTime;
  final int examDuration;
  final int numberOfQuestions;
  final int perfectScore;
  final List<Announcement> announcements;

  Exam({
    required this.subject,
    required this.examStartTime,
    required this.examDuration,
    required this.numberOfQuestions,
    required this.perfectScore,
    required this.announcements,
  }) : examEndTime = examStartTime.add(Duration(minutes: examDuration));

  String buildExamTimeString() {
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

    return '$startHour$startMinute~ $endHour$endMinute(${examDuration}m)';
  }
}
