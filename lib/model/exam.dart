import 'announcement.dart';
import 'relative_time.dart';

class Exam {
  final String subjectName;
  final DateTime examStartTime;
  final DateTime examEndTime;
  final int examDuration;
  final int numberOfQuestions;
  final int perfectScore;
  final List<Announcement> announcementTimeline;

  Exam({
    required this.subjectName,
    required this.examStartTime,
    required this.examDuration,
    required this.numberOfQuestions,
    required this.perfectScore,
    required this.announcementTimeline,
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

List<Exam> defaultExams = [
  Exam(
    subjectName: '국어',
    examStartTime: DateTimeBuilder.fromHourMinute(8, 40),
    examDuration: 80,
    numberOfQuestions: 45,
    perfectScore: 100,
    announcementTimeline: [
      Announcement(
        title: '1교시 예비령',
        time: RelativeTime.beforeStart(minutes: 15),
      ),
      Announcement(
        title: '1교시 준비령',
        time: RelativeTime.beforeStart(minutes: 5),
      ),
      Announcement(
        title: '1교시 본령',
        time: RelativeTime.beforeStart(minutes: 0),
      ),
      Announcement(
        title: '1교시 종료령',
        time: RelativeTime.afterFinish(minutes: 0),
      ),
    ],
  ),
  Exam(
    subjectName: '수학',
    examStartTime: DateTimeBuilder.fromHourMinute(10, 30),
    examDuration: 100,
    numberOfQuestions: 30,
    perfectScore: 100,
    announcementTimeline: [
      Announcement(
        title: '2교시 예비령',
        time: RelativeTime.beforeStart(minutes: 10),
      ),
      Announcement(
        title: '2교시 준비령',
        time: RelativeTime.beforeStart(minutes: 5),
      ),
      Announcement(
        title: '2교시 본령',
        time: RelativeTime.beforeStart(minutes: 0),
      ),
      Announcement(
        title: '2교시 종료령',
        time: RelativeTime.afterFinish(minutes: 0),
      ),
    ],
  ),
  Exam(
    subjectName: '영어',
    examStartTime: DateTimeBuilder.fromHourMinute(13, 10),
    examDuration: 70,
    numberOfQuestions: 45,
    perfectScore: 100,
    announcementTimeline: [
      Announcement(
        title: '3교시 예비령',
        time: RelativeTime.beforeStart(minutes: 10),
      ),
      Announcement(
        title: '3교시 준비령',
        time: RelativeTime.beforeStart(minutes: 5),
      ),
      Announcement(
        title: '3교시 본령',
        time: RelativeTime.beforeStart(minutes: 0),
      ),
      Announcement(
        title: '3교시 종료령',
        time: RelativeTime.afterFinish(minutes: 0),
      ),
    ],
  ),
  Exam(
    subjectName: '한국사',
    examStartTime: DateTimeBuilder.fromHourMinute(14, 50),
    examDuration: 30,
    numberOfQuestions: 20,
    perfectScore: 50,
    announcementTimeline: [
      Announcement(
        title: '4교시 예비령',
        time: RelativeTime.beforeStart(minutes: 10),
      ),
      Announcement(
        title: '4교시 준비령',
        time: RelativeTime.beforeStart(minutes: 5),
      ),
      Announcement(
        title: '4교시 본령',
        time: RelativeTime.beforeStart(minutes: 0),
      ),
      Announcement(
        title: '4교시 종료령',
        time: RelativeTime.afterFinish(minutes: 0),
      ),
    ],
  ),
  Exam(
    subjectName: '탐구',
    examStartTime: DateTimeBuilder.fromHourMinute(15, 35),
    examDuration: 62,
    numberOfQuestions: 20,
    perfectScore: 50,
    announcementTimeline: [
      Announcement(
        title: '4교시 예비령 (탐구1)',
        time: RelativeTime.beforeStart(minutes: 10),
      ),
      Announcement(
        title: '4교시 준비령 (탐구1)',
        time: RelativeTime.beforeStart(minutes: 5),
      ),
      Announcement(
        title: '4교시 본령 (탐구1)',
        time: RelativeTime.beforeStart(minutes: 0),
      ),
      Announcement(
        title: '4교시 종료령 (탐구1)',
        time: RelativeTime.afterStart(minutes: 30),
      ),
      Announcement(
        title: '4교시 본령 (탐구2)',
        time: RelativeTime.afterStart(minutes: 32),
      ),
      Announcement(
        title: '4교시 종료령 (탐구2)',
        time: RelativeTime.afterFinish(minutes: 0),
      ),
    ],
  ),
  Exam(
    subjectName: '제2외국어/한문',
    examStartTime: DateTimeBuilder.fromHourMinute(17, 5),
    examDuration: 40,
    numberOfQuestions: 30,
    perfectScore: 50,
    announcementTimeline: [
      Announcement(
        title: '5교시 예비령',
        time: RelativeTime.beforeStart(minutes: 10),
      ),
      Announcement(
        title: '5교시 준비령',
        time: RelativeTime.beforeStart(minutes: 5),
      ),
      Announcement(
        title: '5교시 본령',
        time: RelativeTime.beforeStart(minutes: 0),
      ),
      Announcement(
        title: '5교시 종료령',
        time: RelativeTime.afterFinish(minutes: 0),
      ),
    ],
  ),
];

extension DateTimeBuilder on DateTime {
  static DateTime fromHourMinute(int hour, int minute) => DateTime(0, 1, 1, hour, minute);
}

extension on DateTime {
  int get hour12 {
    if (hour > 12) {
      return hour - 12;
    } else {
      return hour;
    }
  }
}
