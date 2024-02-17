import 'package:freezed_annotation/freezed_annotation.dart';

import '../repository/exam/exam_repository.dart';
import 'announcement.dart';
import 'relative_time.dart';

enum Subject {
  @JsonValue('language')
  language(
    defaultName: '국어',
    defaultAnnouncements: [
      Announcement(
        title: '예비령',
        time: RelativeTime.beforeStart(minutes: 15),
        fileName: '003_1_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        fileName: '004_1_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        fileName: '005_1_start.mp3',
      ),
      Announcement(
        title: '10분전',
        time: RelativeTime.beforeFinish(minutes: 10),
        fileName: '006_1_10min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        fileName: '007_1_finish.mp3',
      ),
    ],
  ),
  @JsonValue('math')
  math(
    defaultName: '수학',
    defaultAnnouncements: [
      Announcement(
        title: '예비령',
        time: RelativeTime.beforeStart(minutes: 10),
        fileName: '009_2_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        fileName: '010_2_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        fileName: '011_2_start.mp3',
      ),
      Announcement(
        title: '10분전',
        time: RelativeTime.beforeFinish(minutes: 10),
        fileName: '012_2_10min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        fileName: '013_2_finish.mp3',
      ),
    ],
  ),
  @JsonValue('english')
  english(
    defaultName: '영어',
    defaultAnnouncements: [
      Announcement(
        title: '예비령',
        time: RelativeTime.beforeStart(minutes: 10),
        fileName: '015_3_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        fileName: '016_3_prepare.mp3',
      ),
      Announcement(
        title: '본령 (타종X)',
        time: RelativeTime.afterStart(minutes: 0),
      ),
      Announcement(
        title: '듣기 끝',
        time: RelativeTime.afterStart(minutes: 23),
      ),
      Announcement(
        title: '10분전',
        time: RelativeTime.beforeFinish(minutes: 10),
        fileName: '017_3_10min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        fileName: '018_3_finish.mp3',
      ),
    ],
  ),
  @JsonValue('history')
  history(
    defaultName: '한국사',
    defaultAnnouncements: [
      Announcement(
        title: '예비령',
        time: RelativeTime.beforeStart(minutes: 10),
        fileName: '020_4_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        fileName: '021_4_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        fileName: '022_4_start.mp3',
      ),
      Announcement(
        title: '5분전',
        time: RelativeTime.beforeFinish(minutes: 5),
        fileName: '023_4_5min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        fileName: '024_4_finish.mp3',
      ),
    ],
  ),
  @JsonValue('investigation')
  investigation(
    defaultName: '탐구1',
    defaultAnnouncements: [
      Announcement(
        title: '예비령',
        time: RelativeTime.beforeStart(minutes: 10),
        fileName: '025_4_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        fileName: '026_4_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        fileName: '027_4_start_first.mp3',
      ),
      Announcement(
        title: '5분전',
        time: RelativeTime.afterStart(minutes: 25),
        fileName: '028_4_5min_left_first.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterStart(minutes: 30),
        fileName: '029_4_finish_first.mp3',
      ),
    ],
  ),
  @JsonValue('investigation2')
  investigation2(
    defaultName: '탐구2',
    defaultAnnouncements: [
      Announcement(
        title: '종료령',
        time: RelativeTime.beforeStart(minutes: 2),
        fileName: '029_4_finish_first.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        fileName: '030_4_start_second.mp3',
      ),
      Announcement(
        title: '5분전',
        time: RelativeTime.beforeFinish(minutes: 5),
        fileName: '031_4_5min_left_second.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        fileName: '032_4_finish_second_1.mp3',
      ),
    ],
  ),
  @JsonValue('secondLanguage')
  secondLanguage(
    defaultName: '제2외국어/한문',
    defaultAnnouncements: [
      Announcement(
        title: '예비령',
        time: RelativeTime.beforeStart(minutes: 10),
        fileName: '034_5_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        fileName: '035_5_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        fileName: '036_5_start.mp3',
      ),
      Announcement(
        title: '10분전',
        time: RelativeTime.beforeFinish(minutes: 10),
        fileName: '037_5_10min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        fileName: '038_5_finish.mp3',
      ),
    ],
  );

  const Subject({
    required this.defaultName,
    required this.defaultAnnouncements,
  });

  final String defaultName;
  final List<Announcement> defaultAnnouncements;

  int get defaultExamDuration {
    final defaultExam = defaultExams.firstWhere((exam) {
      return exam.subject == this;
    });
    return defaultExam.durationMinutes;
  }
}

final defaultSubjectNameMap = {
  for (final subject in Subject.values) subject: subject.defaultName,
};
