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

  DateTime getDefaultStartDate({List<ExamRecord>? records}) {
    records ??= originalRecords;
    return (records.isEmpty
            ? DateTime.now().subtract(const Duration(days: 365))
            : records.first.examStartedTime)
        .toDate();
  }

  DateTime getDefaultEndDate({List<ExamRecord>? records}) {
    records ??= originalRecords;
    return (records.isEmpty
            ? DateTime.now()
            : records.last.examStartedTime.isAfter(DateTime.now())
                ? records.last.examStartedTime
                : DateTime.now())
        .toDate();
  }

  DateTimeRange get defaultDateRange =>
      DateTimeRange(start: getDefaultStartDate(), end: getDefaultEndDate());
}
