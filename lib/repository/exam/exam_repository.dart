import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../model/exam.dart';
import '../../model/subject.dart';
import '../../util/date_time_extension.dart';

@lazySingleton
class ExamRepository {
  final CollectionReference<Exam> _examsCollection =
      FirebaseFirestore.instance.collection('exams').withConverter(
            fromFirestore: (snapshot, _) => Exam.fromJson(snapshot.data()!),
            toFirestore: (exam, _) => exam.toJson(),
          );

  void addExam(Exam exam) {
    _examsCollection.doc(exam.id).set(exam);
  }

  Future<List<Exam>> getMyExams(String userId) async {
    final exams =
        await _examsCollection.where('userId', isEqualTo: userId).get();
    return exams.docs.map((snapshot) => snapshot.data()).toList();
  }

  void updateExam(Exam exam) {
    _examsCollection.doc(exam.id).update(exam.toJson());
  }

  void deleteExam(String examId) {
    _examsCollection.doc(examId).delete();
  }
}

final List<Exam> defaultExams = [
  Exam(
    id: Subject.language.name,
    subject: Subject.language,
    name: Subject.language.defaultName,
    number: 1,
    startTime: DateTimeBuilder.fromHourMinute(8, 40),
    durationMinutes: 80,
    numberOfQuestions: 45,
    perfectScore: 100,
    color: 0xFF55B99E,
  ),
  Exam(
    id: Subject.math.name,
    subject: Subject.math,
    name: Subject.math.defaultName,
    number: 2,
    startTime: DateTimeBuilder.fromHourMinute(10, 30),
    durationMinutes: 100,
    numberOfQuestions: 30,
    perfectScore: 100,
    color: 0xFFE05FA9,
  ),
  Exam(
    id: Subject.english.name,
    subject: Subject.english,
    name: Subject.english.defaultName,
    number: 3,
    startTime: DateTimeBuilder.fromHourMinute(13, 10),
    durationMinutes: 70,
    numberOfQuestions: 45,
    perfectScore: 100,
    color: 0xFF0098C3,
  ),
  Exam(
    id: Subject.history.name,
    subject: Subject.history,
    name: Subject.history.defaultName,
    number: 4,
    startTime: DateTimeBuilder.fromHourMinute(14, 50),
    durationMinutes: 30,
    numberOfQuestions: 20,
    perfectScore: 50,
    color: 0xFF714925,
  ),
  Exam(
    id: Subject.investigation.name,
    subject: Subject.investigation,
    name: Subject.investigation.defaultName,
    number: 4,
    startTime: DateTimeBuilder.fromHourMinute(15, 35),
    durationMinutes: 30,
    numberOfQuestions: 20,
    perfectScore: 50,
    color: 0xFF7B4DB9,
  ),
  Exam(
    id: Subject.investigation2.name,
    subject: Subject.investigation2,
    name: Subject.investigation2.defaultName,
    number: 4,
    startTime: DateTimeBuilder.fromHourMinute(16, 7),
    durationMinutes: 30,
    numberOfQuestions: 20,
    perfectScore: 50,
    color: 0xFF3331A3,
  ),
  Exam(
    id: Subject.secondLanguage.name,
    subject: Subject.secondLanguage,
    name: Subject.secondLanguage.defaultName,
    number: 5,
    startTime: DateTimeBuilder.fromHourMinute(17, 5),
    durationMinutes: 40,
    numberOfQuestions: 30,
    perfectScore: 50,
    color: 0xFFF39328,
  ),
];
