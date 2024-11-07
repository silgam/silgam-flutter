part of 'exam_overview_cubit.dart';

@freezed
class ExamOverviewState with _$ExamOverviewState {
  const ExamOverviewState._();

  const factory ExamOverviewState({
    @Default({}) Map<Exam, List<LapTimeItemGroup>> examToLapTimeItemGroups,
    @Default(false) bool isUsingExampleLapTimeItemGroups,
    @Default({}) Map<Exam, String> examToRecordIds,
    @Default(false) bool isAutoSavingRecords,
  }) = _ExamOverviewState;

  String? getPrefillFeedbackForExamRecord(Exam exam) {
    final lapTimeItemGroups = examToLapTimeItemGroups[exam] ?? [];

    return (lapTimeItemGroups.isEmpty || isUsingExampleLapTimeItemGroups)
        ? null
        : lapTimeItemGroups.toCopyableString();
  }
}
