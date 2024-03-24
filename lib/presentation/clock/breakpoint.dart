import 'package:collection/collection.dart';

import '../../model/announcement.dart';
import '../../model/exam.dart';
import '../../model/timetable.dart';

class BreakpointGroup {
  final Exam exam;
  final List<Breakpoint> breakpoints;

  BreakpointGroup({
    required this.exam,
    required this.breakpoints,
  });

  static List<BreakpointGroup> createBreakpointGroupsFromTimetable(
    Timetable timetable,
  ) {
    final breakpointGroups = <BreakpointGroup>[];

    timetable.items.forEachIndexed((index, currentItem) {
      final itemStartTime = index == 0
          ? timetable.startTime
          : breakpointGroups.last.breakpoints.last.time.add(
              Duration(minutes: timetable.items[index - 1].breakMinutesAfter),
            );
      final examStartTime = itemStartTime.add(
        Duration(minutes: currentItem.exam.subject.minutesBeforeExamStart),
      );

      final currentItemBreakpoints = Breakpoint._createBreakpointsFromExam(
        currentItem.exam,
        examStartTime,
      );
      if (breakpointGroups.lastOrNull?.breakpoints.lastOrNull?.time ==
          currentItemBreakpoints.firstOrNull?.time) {
        breakpointGroups.lastOrNull?.breakpoints.removeLast();
      }
      breakpointGroups.add(BreakpointGroup(
        exam: currentItem.exam,
        breakpoints: currentItemBreakpoints,
      ));
    });

    return breakpointGroups;
  }
}

class Breakpoint {
  final String title;
  final DateTime time;
  final Announcement announcement;

  Breakpoint({
    required this.title,
    required this.time,
    required this.announcement,
  });

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
