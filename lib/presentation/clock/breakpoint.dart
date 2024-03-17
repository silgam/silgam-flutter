import 'package:collection/collection.dart';

import '../../model/announcement.dart';
import '../../model/exam.dart';
import '../../model/timetable.dart';

class Breakpoint {
  final String title;
  final DateTime time;
  final Announcement announcement;

  Breakpoint({
    required this.title,
    required this.time,
    required this.announcement,
  });

  static List<Breakpoint> createBreakpointsFromTimetable(Timetable timetable) {
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

      final currentItemBreakpoints = _createBreakpointsFromExam(
        currentItem.exam,
        examStartTime,
      );
      if (breakpoints.lastOrNull?.time ==
          currentItemBreakpoints.firstOrNull?.time) {
        currentItemBreakpoints.removeAt(0);
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
      final DateTime breakpointTime = announcement.time.calculateBreakpointTime(
        examStartTime,
        examStartTime.add(Duration(minutes: exam.durationMinutes)),
      );

      breakpoints.add(Breakpoint(
        title: announcement.title,
        time: breakpointTime,
        announcement: announcement,
      ));
    }

    return breakpoints;
  }
}
