part of 'stat_cubit.dart';

@freezed
class StatState with _$StatState {
  const StatState._();

  const factory StatState({
    @Default([]) List<ExamRecord> originalRecords,
    @Default({}) Map<Subject, List<ExamRecord>> records,
    @Default(false) bool isLoading,
    @Default('') String searchQuery,
    @Default([]) List<Subject> selectedSubjects,
    @Default(false) bool isDateRangeSet,
    required DateTimeRange dateRange,
    required ExamValueType selectedExamValueType,
  }) = _StatState;

  factory StatState.initial() {
    return StatState(
      dateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 365)),
        end: DateTime.now(),
      ),
      selectedExamValueType: StatView.examValueTypes.first,
    );
  }

  DateTime get defaultStartDate => (originalRecords.isEmpty
          ? DateTime.now().subtract(const Duration(days: 365))
          : originalRecords.first.examStartedTime)
      .toDate();

  DateTime get defaultEndDate => (originalRecords.isEmpty
          ? DateTime.now()
          : originalRecords.last.examStartedTime.isAfter(DateTime.now())
              ? originalRecords.last.examStartedTime
              : DateTime.now())
      .toDate();

  DateTimeRange get defaultDateRange =>
      DateTimeRange(start: defaultStartDate, end: defaultEndDate);
}
