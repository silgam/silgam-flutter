import '../../model/timetable.dart';
import '../exam/exam_repository.dart';

final List<Timetable> defaultTimetables = [
  ...defaultExams.map((exam) => Timetable(
        startTime: exam.startTime,
        items: [
          TimetableItem(exam: exam),
        ],
      )),
];
