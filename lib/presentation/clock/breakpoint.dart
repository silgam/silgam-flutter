import 'package:collection/collection.dart';

import '../../model/announcement.dart';
import '../../model/exam.dart';
import '../../model/relative_time.dart';
import '../../model/timetable.dart';

class Breakpoint {
  final String title;
  final DateTime time;
  final Announcement announcement;
  final Exam exam;
  final bool isFirstInExam;

  Breakpoint({
    required this.title,
    required this.time,
    required this.announcement,
    required this.exam,
    required this.isFirstInExam,
  });

  static List<Breakpoint> createBreakpointsFromTimetable(
    Timetable timetable,
  ) {
    final breakpoints = <Breakpoint>[];

    timetable.items.forEachIndexed((index, currentItem) {
      final itemStartTime = index == 0
          ? timetable.startTime
          : breakpoints.last.time.add(
              Duration(minutes: timetable.items[index - 1].breakMinutesAfter),
            );
      final examStartTime = itemStartTime.add(
        Duration(minutes: currentItem.exam.subject.minutesBeforeExamStart),
      );

      final currentItemBreakpoints = Breakpoint._createBreakpointsFromExam(
        currentItem.exam,
        examStartTime,
      );
      if (breakpoints.lastOrNull?.time ==
          currentItemBreakpoints.firstOrNull?.time) {
        breakpoints.removeLast();
      }
      breakpoints.addAll(currentItemBreakpoints);
    });

    return breakpoints;
  }

  static List<Breakpoint> _createBreakpointsFromExam(
    Exam exam,
    DateTime examStartTime,
  ) {
    final breakpoints = <Breakpoint>[];

    for (final announcement in exam.subject.defaultAnnouncements) {
      if ((announcement.time.type == RelativeTimeType.afterStart ||
              announcement.time.type == RelativeTimeType.beforeFinish) &&
          announcement.time.minutes >= exam.durationMinutes) {
        continue;
      }
      if (!exam.isBeforeFinishAnnouncementEnabled &&
          announcement.purpose == AnnouncementPurpose.beforeFinish) {
        continue;
      }

      final DateTime breakpointTime = announcement.time.calculateBreakpointTime(
        examStartTime,
        examStartTime.add(Duration(minutes: exam.durationMinutes)),
      );

      breakpoints.add(Breakpoint(
        title: announcement.title,
        time: breakpointTime,
        announcement: announcement,
        exam: exam,
        isFirstInExam: breakpoints.isEmpty,
      ));
    }

    return breakpoints;
  }
}
