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
    await _uploadProblemImages(record);
    return await _recordsRef.add(record);
  }

  Future<ExamRecord> getExamRecordById(String documentId) async {
    final snapshot = await _recordsRef.doc(documentId).get();
    return snapshot.toExamRecord();
  }

  Future<List<ExamRecord>> getMyExamRecords() async {
    final querySnapshot =
        await _recordsRef.where('userId', isEqualTo: _user.uid).orderBy('examStartedTime', descending: true).get();
    final examRecords = querySnapshot.docs.map((snapshot) => snapshot.toExamRecord()).toList();
    return examRecords;
  }

  Future<void> updateExamRecord(ExamRecord oldRecord, ExamRecord newRecord) async {
    List<String> oldImages = oldRecord.reviewProblems.expand((element) => element.imagePaths).toList();
    List<String> newImages = newRecord.reviewProblems.expand((element) => element.imagePaths).toList();
    for (final oldImage in oldImages) {
      final isImageRemoved = !newImages.contains(oldImage);
      if (isImageRemoved) await _deleteImage(oldImage);
    }
    await _uploadProblemImages(newRecord);
    return await _recordsRef.doc(newRecord.documentId).update(newRecord.toJson());
  }

  Future<void> deleteExamRecord(ExamRecord examRecord) async {
    return await _recordsRef.doc(examRecord.documentId).delete();
  }

  Future<void> _uploadProblemImages(ExamRecord record) async {
    for (final reviewProblem in record.reviewProblems) {
      for (int i = 0; i < reviewProblem.imagePaths.length; i++) {
        if (reviewProblem.imagePaths[i].startsWith('http')) continue;
        final imageUrl = await _uploadImage(reviewProblem.imagePaths[i]);
        reviewProblem.imagePaths[i] = imageUrl;
      }
    }
  }

  Future<String> _uploadImage(String imagePath) async {
    final reference = _problemImagesRef.child(_user.uid).child(_uuid.v1());
    final TaskSnapshot snapshot = await reference.putFile(File(imagePath));
    final String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<void> _deleteImage(String imagePath) async {
    final reference = FirebaseStorage.instance.refFromURL(imagePath);
    return await reference.delete();
  }
}

extension on DocumentSnapshot<ExamRecord> {
  ExamRecord toExamRecord() {
    ExamRecord record = data()!;
    record.documentId = id;
    return record;
  }
}
