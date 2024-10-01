part of 'exam_overview_cubit.dart';

@freezed
class ExamOverviewState with _$ExamOverviewState {
  const factory ExamOverviewState({
    @Default({}) Map<Exam, List<LapTimeItemGroup>> examToLapTimeItemGroups,
    @Default(false) bool isUsingExampleLapTimeItemGroups,
    @Default({}) Set<String> recordedExamIds,
  }) = _ExamOverviewState;
}
