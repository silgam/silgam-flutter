part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const AppState._();

  const factory AppState({
    User? me,
    @Default(ProductBenefit.initial) ProductBenefit productBenefit,
    @Default(ProductBenefit.initial) ProductBenefit freeProductBenefit,
    @Default(false) bool isOffline,
    @Default([]) List<Exam> customExams,
  }) = _AppState;

  bool get isSignedIn => me != null;
  bool get isNotSignedIn => me == null;

  Map<Subject, String>? get customSubjectNameMap {
    if (productBenefit.isCustomSubjectNameAvailable) {
      return me?.customSubjectNameMap;
    }
    return null;
  }

  List<Exam> get allExams => [...customExams, ...defaultExams];

  List<Timetable> get allTimetables {
    final allExams = this.allExams;

    return [
      ...allExams.map((exam) => Timetable(
            name: exam.name,
            startTime: exam.timetableStartTime,
            items: [
              TimetableItem(exam: exam),
            ],
          )),
    ]..insert(
        allExams
            .lastIndexWhere((exam) => exam.subject == Subject.investigation),
        Timetable(
          name: '탐구 연속',
          startTime: Subject.investigation.defaultExam.timetableStartTime,
          items: [
            TimetableItem(exam: Subject.investigation.defaultExam),
            TimetableItem(exam: Subject.investigation2.defaultExam),
          ],
        ),
      );
  }
}
