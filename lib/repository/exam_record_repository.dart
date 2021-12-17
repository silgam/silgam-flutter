import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../model/exam_record.dart';
import '../repository/user_repository.dart';

class ExamRecordRepository {
  ExamRecordRepository._privateConstructor();

  static final ExamRecordRepository _instance = ExamRecordRepository._privateConstructor();

  factory ExamRecordRepository() => _instance;

  final CollectionReference<ExamRecord> _recordsRef =
      FirebaseFirestore.instance.collection('exam_records').withConverter(
            fromFirestore: (snapshot, _) => ExamRecord.fromJson(snapshot.data()!),
            toFirestore: (record, _) => record.toJson(),
          );

  User get _user => UserRepository().getUser();
  final Reference _problemImagesRef = FirebaseStorage.instance.ref('problem_images');
  final Uuid _uuid = const Uuid();

  Future<DocumentReference<ExamRecord>> addExamRecord(ExamRecord record) async {
    for (final reviewProblem in record.reviewProblems) {
      for (int i = 0; i < reviewProblem.imagePaths.length; i++) {
        final imageUrl = await _uploadImage(reviewProblem.imagePaths[i]);
        reviewProblem.imagePaths[i] = imageUrl;
      }
    }
    return await _recordsRef.add(record);
  }

  Future<List<ExamRecord>> getMyExamRecords() async {
    final querySnapshot = await _recordsRef.where('userId', isEqualTo: _user.uid).get();
    final examRecords = querySnapshot.docs.map((documentSnapshot) => documentSnapshot.data()).toList();
    return examRecords;
  }

  Future<String> _uploadImage(String imagePath) async {
    final reference = _problemImagesRef.child(_user.uid).child(_uuid.v1());
    final TaskSnapshot snapshot = await reference.putFile(File(imagePath));
    final String url = await snapshot.ref.getDownloadURL();
    return url;
  }
}
