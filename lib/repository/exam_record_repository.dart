import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/exam_record.dart';
import '../repository/user_repository.dart';

class ExamRecordRepository {
  ExamRecordRepository._privateConstructor();

  static final ExamRecordRepository _instance = ExamRecordRepository._privateConstructor();

  factory ExamRecordRepository() => _instance;

  final recordsRef = FirebaseFirestore.instance.collection('exam_records').withConverter(
        fromFirestore: (snapshot, _) => ExamRecord.fromJson(snapshot.data()!),
        toFirestore: (record, _) => record.toJson(),
      );

  User get user => UserRepository().getUser();

  Future<DocumentReference<ExamRecord>> addExamRecord(ExamRecord record) async {
    return await recordsRef.add(record);
  }

  Future<List<ExamRecord>> getMyExamRecords() async {
    final querySnapshot = await recordsRef.where('userId', isEqualTo: user.uid).get();
    final examRecords = querySnapshot.docs.map((documentSnapshot) => documentSnapshot.data()).toList();
    return examRecords;
  }
}
