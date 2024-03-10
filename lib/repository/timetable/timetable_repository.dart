import '../../model/subject.dart';
import '../../model/timetable.dart';
import '../exam/exam_repository.dart';

final List<Timetable> defaultTimetables = [
  ...defaultExams.map((exam) => Timetable(
        name: exam.name,
        startTime: exam.startTime,
        items: [
          TimetableItem(exam: exam),
        ],
      )),
]..insert(
    defaultExams.indexWhere((exam) => exam.subject == Subject.investigation),
    Timetable(
      name: '탐구 연속',
      startTime: Subject.investigation.defaultExam.startTime,
      items: [
        TimetableItem(exam: Subject.investigation.defaultExam),
        TimetableItem(exam: Subject.investigation2.defaultExam),
      ],
    ),
  );
