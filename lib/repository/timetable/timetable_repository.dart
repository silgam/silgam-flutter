import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../model/timetable.dart';

@lazySingleton
class TimetableRepository {
  final CollectionReference<Timetable> _timetablesRef =
      FirebaseFirestore.instance.collection('timetables').withConverter(
            fromFirestore: (snapshot, _) =>
                Timetable.fromJson(snapshot.data()!),
            toFirestore: (timetable, _) => timetable.toJson(),
          );

  void addTimetable(Timetable timetable) {
    _timetablesRef.doc(timetable.id).set(timetable);
  }

  Future<List<Timetable>> getMyTimetables(String userId) async {
    final timetables =
        await _timetablesRef.where('userId', isEqualTo: userId).get();
    return timetables.docs.map((snapshot) => snapshot.data()).toList();
  }

  void updateTimetable(Timetable timetable) {
    _timetablesRef.doc(timetable.id).update(timetable.toJson());
  }

  void deleteTimetable(String timetableId) {
    _timetablesRef.doc(timetableId).delete();
  }
}
