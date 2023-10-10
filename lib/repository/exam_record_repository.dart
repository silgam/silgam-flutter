import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../model/exam_record.dart';

@lazySingleton
class ExamRecordRepository {
  final CollectionReference<ExamRecord> _recordsRef = FirebaseFirestore.instance
      .collection('exam_records')
      .withConverter(
        fromFirestore: (snapshot, _) => ExamRecord.fromJson(snapshot.data()!),
        toFirestore: (record, _) => record.toJson(),
      );
  final Reference _problemImagesRef =
      FirebaseStorage.instance.ref('problem_images');

  Future<ExamRecord> addExamRecord({
    required String userId,
    required ExamRecord record,
  }) async {
    await _uploadProblemImages(userId, record);
    _recordsRef.doc(record.id).set(record);
    return record;
  }

  Future<List<ExamRecord>> getMyExamRecords(String userId) async {
    final querySnapshot = await _recordsRef
        .where('userId', isEqualTo: userId)
        .orderBy('examStartedTime', descending: true)
        .get();
    final examRecords =
        querySnapshot.docs.map((snapshot) => snapshot.data()).toList();
    return examRecords;
  }

  Future<ExamRecord> updateExamRecord({
    required String userId,
    required ExamRecord oldRecord,
    required ExamRecord newRecord,
  }) async {
    List<String> oldImages = oldRecord.reviewProblems
        .expand((element) => element.imagePaths)
        .toList();
    List<String> newImages = newRecord.reviewProblems
        .expand((element) => element.imagePaths)
        .toList();
    for (final oldImage in oldImages) {
      final isImageRemoved = !newImages.contains(oldImage);
      if (isImageRemoved) await _deleteImage(oldImage);
    }
    await _uploadProblemImages(userId, newRecord);
    _recordsRef.doc(newRecord.id).update(newRecord.toJson());
    return newRecord;
  }

  Future<void> deleteExamRecord(ExamRecord examRecord) async {
    final allImages =
        examRecord.reviewProblems.expand((element) => element.imagePaths);
    for (final imageUrl in allImages) {
      await _deleteImage(imageUrl);
    }
    _recordsRef.doc(examRecord.id).delete();
  }

  Future<void> _uploadProblemImages(String userId, ExamRecord record) async {
    for (final reviewProblem in record.reviewProblems) {
      for (int i = 0; i < reviewProblem.imagePaths.length; i++) {
        if (reviewProblem.imagePaths[i].startsWith('http')) continue;
        final imageUrl =
            await _uploadImage(userId, reviewProblem.imagePaths[i]);
        reviewProblem.imagePaths[i] = imageUrl;
      }
    }
  }

  Future<String> _uploadImage(String userId, String imagePath) async {
    final File imageFile = File(imagePath);
    final reference = _problemImagesRef.child(userId).child(const Uuid().v1());
    final TaskSnapshot snapshot = await reference.putFile(imageFile);
    final String url = await snapshot.ref.getDownloadURL();
    await imageFile.delete();
    return url;
  }

  Future<void> _deleteImage(String imagePath) async {
    final reference = FirebaseStorage.instance.refFromURL(imagePath);
    return await reference.delete();
  }
}
