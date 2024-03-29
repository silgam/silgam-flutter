import '../../model/announcement.dart';
import '../../model/exam.dart';
import '../../model/relative_time.dart';
import '../../model/subject.dart';
import '../../util/date_time_extension.dart';

List<Exam> get defaultExams {
  return [
    Exam(
      subject: Subject.language,
      examName: Subject.language.subjectName,
      examNumber: 1,
      examStartTime: DateTimeBuilder.fromHourMinute(8, 40),
      examDuration: 80,
      numberOfQuestions: 45,
      perfectScore: 100,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 15),
          fileName: '003_1_preliminary.mp3',
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
          fileName: '004_1_prepare.mp3',
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.afterStart(minutes: 0),
          fileName: '005_1_start.mp3',
        ),
        const Announcement(
          title: '10분전',
          time: RelativeTime.beforeFinish(minutes: 10),
          fileName: '006_1_10min_left.mp3',
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
          fileName: '007_1_finish.mp3',
        ),
      ],
    ),
    Exam(
      subject: Subject.math,
      examName: Subject.math.subjectName,
      examNumber: 2,
      examStartTime: DateTimeBuilder.fromHourMinute(10, 30),
      examDuration: 100,
      numberOfQuestions: 30,
      perfectScore: 100,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 10),
          fileName: '009_2_preliminary.mp3',
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
          fileName: '010_2_prepare.mp3',
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.afterStart(minutes: 0),
          fileName: '011_2_start.mp3',
        ),
        const Announcement(
          title: '10분전',
          time: RelativeTime.beforeFinish(minutes: 10),
          fileName: '012_2_10min_left.mp3',
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
          fileName: '013_2_finish.mp3',
        ),
      ],
    ),
    Exam(
      subject: Subject.english,
      examName: Subject.english.subjectName,
      examNumber: 3,
      examStartTime: DateTimeBuilder.fromHourMinute(13, 10),
      examDuration: 70,
      numberOfQuestions: 45,
      perfectScore: 100,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 10),
          fileName: '015_3_preliminary.mp3',
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
          fileName: '016_3_prepare.mp3',
        ),
        const Announcement(
          title: '본령 (타종X)',
          time: RelativeTime.afterStart(minutes: 0),
        ),
        const Announcement(
          title: '듣기 끝',
          time: RelativeTime.afterStart(minutes: 23),
        ),
        const Announcement(
          title: '10분전',
          time: RelativeTime.beforeFinish(minutes: 10),
          fileName: '017_3_10min_left.mp3',
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
          fileName: '018_3_finish.mp3',
        ),
      ],
    ),
    Exam(
      subject: Subject.history,
      examName: Subject.history.subjectName,
      examNumber: 4,
      examStartTime: DateTimeBuilder.fromHourMinute(14, 50),
      examDuration: 30,
      numberOfQuestions: 20,
      perfectScore: 50,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 10),
          fileName: '020_4_preliminary.mp3',
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
          fileName: '021_4_prepare.mp3',
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.afterStart(minutes: 0),
          fileName: '022_4_start.mp3',
        ),
        const Announcement(
          title: '5분전',
          time: RelativeTime.beforeFinish(minutes: 5),
          fileName: '023_4_5min_left.mp3',
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
          fileName: '024_4_finish.mp3',
        ),
      ],
    ),
    Exam(
      subject: Subject.investigation,
      examName: '탐구', // 예외
      examNumber: 4,
      examStartTime: DateTimeBuilder.fromHourMinute(15, 35),
      examDuration: 62,
      numberOfQuestions: 20,
      perfectScore: 50,
      announcements: [
        Announcement(
          title: '예비령 (${Subject.investigation.subjectName})',
          time: const RelativeTime.beforeStart(minutes: 10),
          fileName: '025_4_preliminary.mp3',
        ),
        Announcement(
          title: '준비령 (${Subject.investigation.subjectName})',
          time: const RelativeTime.beforeStart(minutes: 5),
          fileName: '026_4_prepare.mp3',
        ),
        Announcement(
          title: '본령 (${Subject.investigation.subjectName})',
          time: const RelativeTime.afterStart(minutes: 0),
          fileName: '027_4_start_first.mp3',
        ),
        Announcement(
          title: '5분전 (${Subject.investigation.subjectName})',
          time: const RelativeTime.afterStart(minutes: 25),
          fileName: '028_4_5min_left_first.mp3',
        ),
        Announcement(
          title: '종료령 (${Subject.investigation.subjectName})',
          time: const RelativeTime.afterStart(minutes: 30),
          fileName: '029_4_finish_first.mp3',
        ),
        Announcement(
          title: '본령 (${Subject.investigation2.subjectName})',
          time: const RelativeTime.afterStart(minutes: 32),
          fileName: '030_4_start_second.mp3',
        ),
        Announcement(
          title: '5분전 (${Subject.investigation2.subjectName})',
          time: const RelativeTime.beforeFinish(minutes: 5),
          fileName: '031_4_5min_left_second.mp3',
        ),
        Announcement(
          title: '종료령 (${Subject.investigation2.subjectName})',
          time: const RelativeTime.afterFinish(minutes: 0),
          fileName: '032_4_finish_second_1.mp3',
        ),
      ],
    ),
    Exam(
      subject: Subject.secondLanguage,
      examName: Subject.secondLanguage.subjectName,
      examNumber: 5,
      examStartTime: DateTimeBuilder.fromHourMinute(17, 5),
      examDuration: 40,
      numberOfQuestions: 30,
      perfectScore: 50,
      announcements: [
        const Announcement(
          title: '예비령',
          time: RelativeTime.beforeStart(minutes: 10),
          fileName: '034_5_preliminary.mp3',
        ),
        const Announcement(
          title: '준비령',
          time: RelativeTime.beforeStart(minutes: 5),
          fileName: '035_5_prepare.mp3',
        ),
        const Announcement(
          title: '본령',
          time: RelativeTime.afterStart(minutes: 0),
          fileName: '036_5_start.mp3',
        ),
        const Announcement(
          title: '10분전',
          time: RelativeTime.beforeFinish(minutes: 10),
          fileName: '037_5_10min_left.mp3',
        ),
        const Announcement(
          title: '종료령',
          time: RelativeTime.afterFinish(minutes: 0),
          fileName: '038_5_finish.mp3',
        ),
      ],
    ),
  ];
}
