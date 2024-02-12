import '../../model/exam.dart';
import '../../model/subject.dart';
import '../../util/date_time_extension.dart';

List<Exam> get defaultExams {
  return [
    Exam(
      subject: Subject.language,
      name: Subject.language.subjectName,
      number: 1,
      startTime: DateTimeBuilder.fromHourMinute(8, 40),
      durationMinutes: 80,
      numberOfQuestions: 45,
      perfectScore: 100,
      color: 0xFF55B99E,
    ),
    Exam(
      subject: Subject.math,
      name: Subject.math.subjectName,
      number: 2,
      startTime: DateTimeBuilder.fromHourMinute(10, 30),
      durationMinutes: 100,
      numberOfQuestions: 30,
      perfectScore: 100,
      color: 0xFFE05FA9,
    ),
    Exam(
      subject: Subject.english,
      name: Subject.english.subjectName,
      number: 3,
      startTime: DateTimeBuilder.fromHourMinute(13, 10),
      durationMinutes: 70,
      numberOfQuestions: 45,
      perfectScore: 100,
      color: 0xFF0098C3,
    ),
    Exam(
      subject: Subject.history,
      name: Subject.history.subjectName,
      number: 4,
      startTime: DateTimeBuilder.fromHourMinute(14, 50),
      durationMinutes: 30,
      numberOfQuestions: 20,
      perfectScore: 50,
      color: 0xFF714925,
    ),
    Exam(
      subject: Subject.investigation,
      name: Subject.investigation.subjectName,
      number: 4,
      startTime: DateTimeBuilder.fromHourMinute(15, 35),
      durationMinutes: 30,
      numberOfQuestions: 20,
      perfectScore: 50,
      color: 0xFF7B4DB9,
    ),
    Exam(
      subject: Subject.investigation2,
      name: Subject.investigation2.subjectName,
      number: 4,
      startTime: DateTimeBuilder.fromHourMinute(16, 7),
      durationMinutes: 30,
      numberOfQuestions: 20,
      perfectScore: 50,
      color: 0xFF3331A3,
    ),
    Exam(
      subject: Subject.secondLanguage,
      name: Subject.secondLanguage.subjectName,
      number: 5,
      startTime: DateTimeBuilder.fromHourMinute(17, 5),
      durationMinutes: 40,
      numberOfQuestions: 30,
      perfectScore: 50,
      color: 0xFFF39328,
    ),
  ];
}
