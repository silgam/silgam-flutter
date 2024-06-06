import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../model/exam.dart';

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
