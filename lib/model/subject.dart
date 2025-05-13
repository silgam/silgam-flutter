import 'package:freezed_annotation/freezed_annotation.dart';

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
        purpose: AnnouncementPurpose.preliminary,
        fileName: '03_1_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        purpose: AnnouncementPurpose.prepare,
        fileName: '04_1_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        purpose: AnnouncementPurpose.start,
        fileName: '05_1_start.mp3',
      ),
      Announcement(
        title: '종료 10분 전',
        time: RelativeTime.beforeFinish(minutes: 10),
        purpose: AnnouncementPurpose.beforeFinish,
        fileName: '06_1_10min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        purpose: AnnouncementPurpose.finish,
        fileName: '07_1_finish.mp3',
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
        purpose: AnnouncementPurpose.preliminary,
        fileName: '09_2_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        purpose: AnnouncementPurpose.prepare,
        fileName: '10_2_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        purpose: AnnouncementPurpose.start,
        fileName: '11_2_start.mp3',
      ),
      Announcement(
        title: '종료 10분 전',
        time: RelativeTime.beforeFinish(minutes: 10),
        purpose: AnnouncementPurpose.beforeFinish,
        fileName: '12_2_10min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        purpose: AnnouncementPurpose.finish,
        fileName: '13_2_finish.mp3',
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
        purpose: AnnouncementPurpose.preliminary,
        fileName: '15_3_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        purpose: AnnouncementPurpose.prepare,
        fileName: '16_3_prepare.mp3',
      ),
      Announcement(
        title: '본령 (타종X)',
        time: RelativeTime.afterStart(minutes: 0),
        purpose: AnnouncementPurpose.start,
      ),
      Announcement(
        title: '듣기 끝',
        time: RelativeTime.afterStart(minutes: 23),
        purpose: AnnouncementPurpose.listeningEnd,
      ),
      Announcement(
        title: '종료 10분 전',
        time: RelativeTime.beforeFinish(minutes: 10),
        purpose: AnnouncementPurpose.beforeFinish,
        fileName: '17_3_10min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        purpose: AnnouncementPurpose.finish,
        fileName: '18_3_finish.mp3',
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
        purpose: AnnouncementPurpose.preliminary,
        fileName: '20_4_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        purpose: AnnouncementPurpose.prepare,
        fileName: '21_4_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        purpose: AnnouncementPurpose.start,
        fileName: '22_4_start.mp3',
      ),
      Announcement(
        title: '종료 5분 전',
        time: RelativeTime.beforeFinish(minutes: 5),
        purpose: AnnouncementPurpose.beforeFinish,
        fileName: '23_4_5min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        purpose: AnnouncementPurpose.finish,
        fileName: '24_4_finish.mp3',
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
        purpose: AnnouncementPurpose.preliminary,
        fileName: '25_4_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        purpose: AnnouncementPurpose.prepare,
        fileName: '26_4_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        purpose: AnnouncementPurpose.start,
        fileName: '27_4_start_first.mp3',
      ),
      Announcement(
        title: '종료 5분 전',
        time: RelativeTime.beforeFinish(minutes: 5),
        purpose: AnnouncementPurpose.beforeFinish,
        fileName: '28_4_5min_left_first.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        purpose: AnnouncementPurpose.finish,
        fileName: '29_4_finish_first.mp3',
      ),
    ],
  ),
  @JsonValue('investigation2')
  investigation2(
    defaultName: '탐구2',
    defaultAnnouncements: [
      Announcement(
        title: '시험지 교체',
        time: RelativeTime.beforeStart(minutes: 2),
        purpose: AnnouncementPurpose.changePaper,
        fileName: '29_4_finish_first.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        purpose: AnnouncementPurpose.start,
        fileName: '30_4_start_second.mp3',
      ),
      Announcement(
        title: '종료 5분 전',
        time: RelativeTime.beforeFinish(minutes: 5),
        purpose: AnnouncementPurpose.beforeFinish,
        fileName: '31_4_5min_left_second.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        purpose: AnnouncementPurpose.finish,
        fileName: '32_4_finish_second_1.mp3',
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
        purpose: AnnouncementPurpose.preliminary,
        fileName: '34_5_preliminary.mp3',
      ),
      Announcement(
        title: '준비령',
        time: RelativeTime.beforeStart(minutes: 5),
        purpose: AnnouncementPurpose.prepare,
        fileName: '35_5_prepare.mp3',
      ),
      Announcement(
        title: '본령',
        time: RelativeTime.afterStart(minutes: 0),
        purpose: AnnouncementPurpose.start,
        fileName: '36_5_start.mp3',
      ),
      Announcement(
        title: '종료 10분 전',
        time: RelativeTime.beforeFinish(minutes: 10),
        purpose: AnnouncementPurpose.beforeFinish,
        fileName: '37_5_10min_left.mp3',
      ),
      Announcement(
        title: '종료령',
        time: RelativeTime.afterFinish(minutes: 0),
        purpose: AnnouncementPurpose.finish,
        fileName: '38_5_finish.mp3',
      ),
    ],
  );

  const Subject({required this.defaultName, required this.defaultAnnouncements});

  final String defaultName;
  final List<Announcement> defaultAnnouncements;

  int get minutesBeforeExamStart {
    final firstAnnouncement = defaultAnnouncements.firstOrNull;

    if (firstAnnouncement != null && firstAnnouncement.time.type == RelativeTimeType.beforeStart) {
      return firstAnnouncement.time.minutes;
    }
    return 0;
  }

  int get minutesAfterExamFinish {
    final lastAnnouncement = defaultAnnouncements.lastOrNull;

    if (lastAnnouncement != null && lastAnnouncement.time.type == RelativeTimeType.afterFinish) {
      return lastAnnouncement.time.minutes;
    }
    return 0;
  }
}

final defaultSubjectNameMap = {for (final subject in Subject.values) subject: subject.defaultName};
