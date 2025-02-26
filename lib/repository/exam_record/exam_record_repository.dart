import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../model/exam_record.dart';

@lazySingleton
class ExamRecordRepository {
  final CollectionReference<ExamRecord> _recordsRef = FirebaseFirestore.instance
      .collection('exam_records')
      .withConverter(
        fromFirestore: (snapshot, _) => ExamRecord.fromJson(snapshot.data()!),
        toFirestore: (record, _) => record.toJson(),
      );
  final Reference _problemImagesRef = FirebaseStorage.instance.ref(
    'problem_images',
  );

  Future<ExamRecord> addExamRecord(ExamRecord record) async {
    await _uploadProblemImages(record.userId, record);
    _recordsRef.doc(record.id).set(record);
    return record;
  }

  Future<List<ExamRecord>> getMyExamRecords(String userId) async {
    final querySnapshot =
        await _recordsRef
            .where('userId', isEqualTo: userId)
            .orderBy('examStartedTime', descending: true)
            .get();
    final examRecords =
        querySnapshot.docs.map((snapshot) => snapshot.data()).toList();
    return examRecords;
  }

  Future<List<ExamRecord>> getMyExamRecordsByExamId(
    String userId,
    String examId,
  ) async {
    final querySnapshot =
        await _recordsRef
            .where('userId', isEqualTo: userId)
            .where('subject', isEqualTo: examId)
            .get();
    final examRecords =
        querySnapshot.docs.map((snapshot) => snapshot.data()).toList();
    return examRecords;
  }

  Future<ExamRecord> updateExamRecord({
    required ExamRecord oldRecord,
    required ExamRecord newRecord,
  }) async {
    final oldImages = oldRecord.reviewProblems.expand(
      (element) => element.imagePaths,
    );
    final newImages = newRecord.reviewProblems.expand(
      (element) => element.imagePaths,
    );

    final removedImages = oldImages.where(
      (image) => !newImages.contains(image),
    );
    await _deleteImages(removedImages);

    await _uploadProblemImages(newRecord.userId, newRecord);
    _recordsRef.doc(newRecord.id).update(newRecord.toJson());
    return newRecord;
  }

  Future<void> deleteExamRecord(ExamRecord examRecord) async {
    final allImages = examRecord.reviewProblems.expand(
      (element) => element.imagePaths,
    );
    await _deleteImages(allImages);

    _recordsRef.doc(examRecord.id).delete();
  }

  Future<void> _uploadProblemImages(String userId, ExamRecord record) async {
    final List<Future> futures = [];

    for (final reviewProblem in record.reviewProblems) {
      for (final (index, imagePath) in reviewProblem.imagePaths.indexed) {
        if (imagePath.startsWith('http')) continue;

        futures.add(
          _uploadImage(userId, imagePath).then((imageUrl) {
            reviewProblem.imagePaths[index] = imageUrl;
          }),
        );
      }
    }

    await Future.wait(futures);
  }

  Future<String> _uploadImage(String userId, String imagePath) async {
    final File imageFile = File(imagePath);
    final reference = _problemImagesRef.child(userId).child(const Uuid().v1());
    final TaskSnapshot snapshot = await reference.putFile(imageFile);
    final String url = await snapshot.ref.getDownloadURL();
    await imageFile.delete();
    return url;
  }

  Future<void> _deleteImages(Iterable<String> imagePaths) async {
    await Future.wait(imagePaths.map(_deleteImage));
  }

  Future<void> _deleteImage(String imagePath) async {
    await FirebaseStorage.instance.refFromURL(imagePath).delete();
  }
}
