import '../../model/subject.dart';
import '../../model/timetable.dart';
import '../exam/exam_repository.dart';

List<Timetable> defaultTimetables = getDefaultTimetables();

List<Timetable> getDefaultTimetables() {
  return [
    ...defaultExams.map((exam) => Timetable(
          name: exam.name,
          startTime: exam.timetableStartTime,
          items: [
            TimetableItem(exam: exam),
          ],
        )),
  ]..insert(
      defaultExams.indexWhere((exam) => exam.subject == Subject.investigation),
      Timetable(
        name: '탐구 연속',
        startTime: Subject.investigation.defaultExam.timetableStartTime,
        items: [
          TimetableItem(exam: Subject.investigation.defaultExam),
          TimetableItem(exam: Subject.investigation2.defaultExam),
        ],
      ),
    );
}
