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

  List<Exam> getDefaultExams() {
    final customSubjectNameMap = this.customSubjectNameMap;

    return [
      Exam(
        id: Subject.language.name,
        subject: Subject.language,
        name: customSubjectNameMap?[Subject.language] ??
            Subject.language.defaultName,
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
        name: customSubjectNameMap?[Subject.math] ?? Subject.math.defaultName,
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
        name: customSubjectNameMap?[Subject.english] ??
            Subject.english.defaultName,
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
        name: customSubjectNameMap?[Subject.history] ??
            Subject.history.defaultName,
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
        name: customSubjectNameMap?[Subject.investigation] ??
            Subject.investigation.defaultName,
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
        name: customSubjectNameMap?[Subject.investigation2] ??
            Subject.investigation2.defaultName,
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
        name: customSubjectNameMap?[Subject.secondLanguage] ??
            Subject.secondLanguage.defaultName,
        number: 5,
        startTime: DateTimeBuilder.fromHourMinute(17, 5),
        durationMinutes: 40,
        numberOfQuestions: 30,
        perfectScore: 50,
        color: 0xFFF39328,
      ),
    ];
  }

  List<Exam> getAllExams() => [...customExams, ...getDefaultExams()];

  List<Timetable> getAllTimetables() {
    final allExams = getAllExams();

    final timetables = allExams
        .map((exam) => Timetable(
              id: exam.id,
              name: exam.name,
              startTime: exam.timetableStartTime,
              items: [
                TimetableItem(exam: exam),
              ],
            ))
        .toList();

    final defaultInvestigationExam = allExams.firstWhere(
        (exam) => exam.subject == Subject.investigation && !exam.isCustomExam);
    final defaultInvestigation2Exam = allExams.firstWhere(
        (exam) => exam.subject == Subject.investigation2 && !exam.isCustomExam);

    timetables.insert(
      allExams.indexWhere((exam) =>
          exam.subject == Subject.investigation && !exam.isCustomExam),
      Timetable(
        id: 'all-investigation',
        name: '탐구 연속',
        startTime: defaultInvestigationExam.timetableStartTime,
        items: [
          TimetableItem(exam: defaultInvestigationExam),
          TimetableItem(exam: defaultInvestigation2Exam),
        ],
      ),
    );

    final defaultExams = getDefaultExams()
        .where((exam) => exam.subject.includeInAllSubjectsTimetable);
    final Timetable allSubjectsTimetable = Timetable(
      name: '전과목',
      isAllSubjectsTimetable: true,
      startTime: defaultExams.first.timetableStartTime,
      items: defaultExams
          .map((exam) => TimetableItem(
                exam: exam,
                breakMinutesAfter: exam.subject.breakMinutesAfter,
              ))
          .toList(),
    );

    timetables.insert(0, allSubjectsTimetable);

    return timetables;
  }
}

extension on Subject {
  bool get includeInAllSubjectsTimetable => this != Subject.secondLanguage;

  int get breakMinutesAfter => switch (this) {
        Subject.language || Subject.english => 20,
        Subject.math => 50,
        Subject.history => 5,
        Subject.investigation ||
        Subject.investigation2 ||
        Subject.secondLanguage =>
          0,
      };
}
