part of 'stat_cubit.dart';

@freezed
class StatState with _$StatState {
  const factory StatState({
    @Default([]) List<ExamRecord> originalRecords,
    @Default({}) Map<Subject, List<ExamRecord>> records,
    @Default(false) bool isLoading,
    @Default('') String searchQuery,
    @Default([]) List<Subject> selectedSubjects,
    required ExamValueType selectedExamValueType,
  }) = _StatState;

  factory StatState.initial() {
    return StatState(
      selectedExamValueType: StatView.examValueTypes.first,
    );
  }
}
