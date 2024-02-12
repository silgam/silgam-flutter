import '../../model/exam.dart';
import '../../model/subject.dart';
import '../../util/date_time_extension.dart';

List<Exam> get defaultExams {
  return [
    Exam(
      subject: Subject.language,
      examName: Subject.language.subjectName,
      examNumber: 1,
      examStartTime: DateTimeBuilder.fromHourMinute(8, 40),
      examDuration: 80,
      numberOfQuestions: 45,
      perfectScore: 100,
      color: 0xFF55B99E,
    ),
    Exam(
      subject: Subject.math,
      examName: Subject.math.subjectName,
      examNumber: 2,
      examStartTime: DateTimeBuilder.fromHourMinute(10, 30),
      examDuration: 100,
      numberOfQuestions: 30,
      perfectScore: 100,
      color: 0xFFE05FA9,
    ),
    Exam(
      subject: Subject.english,
      examName: Subject.english.subjectName,
      examNumber: 3,
      examStartTime: DateTimeBuilder.fromHourMinute(13, 10),
      examDuration: 70,
      numberOfQuestions: 45,
      perfectScore: 100,
      color: 0xFF0098C3,
    ),
    Exam(
      subject: Subject.history,
      examName: Subject.history.subjectName,
      examNumber: 4,
      examStartTime: DateTimeBuilder.fromHourMinute(14, 50),
      examDuration: 30,
      numberOfQuestions: 20,
      perfectScore: 50,
      color: 0xFF714925,
    ),
    Exam(
      subject: Subject.investigation,
      examName: Subject.investigation.subjectName,
      examNumber: 4,
      examStartTime: DateTimeBuilder.fromHourMinute(15, 35),
      examDuration: 30,
      numberOfQuestions: 20,
      perfectScore: 50,
      color: 0xFF7B4DB9,
    ),
    Exam(
      subject: Subject.investigation2,
      examName: Subject.investigation2.subjectName,
      examNumber: 4,
      examStartTime: DateTimeBuilder.fromHourMinute(16, 7),
      examDuration: 30,
      numberOfQuestions: 20,
      perfectScore: 50,
      color: 0xFF3331A3,
    ),
    Exam(
      subject: Subject.secondLanguage,
      examName: Subject.secondLanguage.subjectName,
      examNumber: 5,
      examStartTime: DateTimeBuilder.fromHourMinute(17, 5),
      examDuration: 40,
      numberOfQuestions: 30,
      perfectScore: 50,
      color: 0xFFF39328,
    ),
  ];
}
