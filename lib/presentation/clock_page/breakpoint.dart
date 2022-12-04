import '../../model/announcement.dart';
import '../../model/exam.dart';
import '../../model/relative_time.dart';

class Breakpoint {
  final String title;
  final DateTime time;
  final Announcement announcement;

  Breakpoint({
    required this.title,
    required this.time,
    required this.announcement,
  });

  static List<Breakpoint> createBreakpointsFromExam(Exam exam) {
    final breakpoints = <Breakpoint>[];

    for (var announcement in exam.announcements) {
      final int minutes = announcement.time.minutes;
      final DateTime breakpointTime;
      switch (announcement.time.type) {
        case RelativeTimeType.beforeStart:
          breakpointTime =
              exam.examStartTime.subtract(Duration(minutes: minutes));
          break;
        case RelativeTimeType.afterStart:
          breakpointTime = exam.examStartTime.add(Duration(minutes: minutes));
          break;
        case RelativeTimeType.beforeFinish:
          breakpointTime =
              exam.examEndTime.subtract(Duration(minutes: minutes));
          break;
        case RelativeTimeType.afterFinish:
          breakpointTime = exam.examEndTime.add(Duration(minutes: minutes));
          break;
      }
      breakpoints.add(Breakpoint(
        title: announcement.title,
        time: breakpointTime,
        announcement: announcement,
      ));
    }

    breakpoints.sort((a, b) => a.time.compareTo(b.time));
    return breakpoints;
  }
}
