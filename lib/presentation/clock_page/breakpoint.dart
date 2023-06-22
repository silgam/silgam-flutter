import '../../model/announcement.dart';
import '../../model/exam.dart';

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
      final DateTime breakpointTime = announcement.time
          .calculateBreakpointTime(exam.examStartTime, exam.examEndTime);
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
