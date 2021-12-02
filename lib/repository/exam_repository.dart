import '../model/announcement.dart';
import '../model/exam.dart';
import '../model/relative_time.dart';
import '../util/date_time_extension.dart';

class ExamRepository {
  static final List<Exam> defaultExams = [
    Exam(
      subjectName: '국어',
      examStartTime: DateTimeBuilder.fromHourMinute(8, 40),
      examDuration: 80,
      numberOfQuestions: 45,
      perfectScore: 100,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 15),
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.beforeStart(minutes: 0),
        ),
        const Announcement(
          title: '10분전',
          time: RelativeTime.beforeFinish(minutes: 10),
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
        ),
      ],
      subjectNumber: 1,
    ),
    Exam(
      subjectName: '수학',
      examStartTime: DateTimeBuilder.fromHourMinute(10, 30),
      examDuration: 100,
      numberOfQuestions: 30,
      perfectScore: 100,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 10),
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.beforeStart(minutes: 0),
        ),
        const Announcement(
          title: '10분전',
          time: RelativeTime.beforeFinish(minutes: 10),
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
        ),
      ],
      subjectNumber: 2,
    ),
    Exam(
      subjectName: '영어',
      examStartTime: DateTimeBuilder.fromHourMinute(13, 10),
      examDuration: 70,
      numberOfQuestions: 45,
      perfectScore: 100,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 10),
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.beforeStart(minutes: 0),
        ),
        const Announcement(
          title: '10분전',
          time: RelativeTime.beforeFinish(minutes: 10),
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
        ),
      ],
      subjectNumber: 3,
    ),
    Exam(
      subjectName: '한국사',
      examStartTime: DateTimeBuilder.fromHourMinute(14, 50),
      examDuration: 30,
      numberOfQuestions: 20,
      perfectScore: 50,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 10),
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.beforeStart(minutes: 0),
        ),
        const Announcement(
          title: '5분전',
          time: RelativeTime.beforeFinish(minutes: 5),
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
        ),
      ],
      subjectNumber: 4,
    ),
    Exam(
      subjectName: '탐구',
      examStartTime: DateTimeBuilder.fromHourMinute(15, 35),
      examDuration: 62,
      numberOfQuestions: 20,
      perfectScore: 50,
      announcements: [
        const Announcement(
          title: '예비령 (탐구1)',
          time: RelativeTime.beforeStart(minutes: 10),
        ),
        const Announcement(
          title: '준비령 (탐구1)',
          time: RelativeTime.beforeStart(minutes: 5),
        ),
        const Announcement(
          title: '본령 (탐구1)',
          time: RelativeTime.beforeStart(minutes: 0),
        ),
        const Announcement(
          title: '5분전 (탐구1)',
          time: RelativeTime.afterStart(minutes: 25),
        ),
        const Announcement(
          title: '종료령 (탐구1)',
          time: RelativeTime.afterStart(minutes: 30),
        ),
        const Announcement(
          title: '본령 (탐구2)',
          time: RelativeTime.afterStart(minutes: 32),
        ),
        const Announcement(
          title: '5분전 (탐구2)',
          time: RelativeTime.beforeFinish(minutes: 5),
        ),
        const Announcement(
          title: '종료령 (탐구2)',
          time: RelativeTime.afterFinish(minutes: 0),
        ),
      ],
      subjectNumber: 4,
    ),
    Exam(
      subjectName: '제2외국어/한문',
      examStartTime: DateTimeBuilder.fromHourMinute(17, 5),
      examDuration: 40,
      numberOfQuestions: 30,
      perfectScore: 50,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 10),
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.beforeStart(minutes: 0),
        ),
        const Announcement(
          title: '10분전',
          time: RelativeTime.beforeFinish(minutes: 10),
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
        ),
      ],
      subjectNumber: 5,
    ),
  ];
}
