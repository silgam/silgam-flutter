part of 'exam_overview_cubit.dart';

@freezed
class ExamOverviewState with _$ExamOverviewState {
  const factory ExamOverviewState({
    @Default([]) List<LapTimeItemGroup> lapTimeItemGroups,
  }) = _ExamOverviewState;
}
