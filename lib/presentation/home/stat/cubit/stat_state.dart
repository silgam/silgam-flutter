part of 'stat_cubit.dart';

@freezed
class StatState with _$StatState {
  const StatState._();

  const factory StatState({
    @Default([]) List<ExamRecord> originalRecords,
    @Default({}) Map<Exam, List<ExamRecord>> records,
    @Default(false) bool isLoading,
    @Default('') String searchQuery,
    @Default([]) List<String> selectedExamIds,
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
      selectedExamValueType: ExamValueType.values.first,
    );
  }

  DateTime getDefaultStartDate({List<ExamRecord>? records}) {
    records ??= originalRecords;
    return (records.isEmpty
            ? DateTime.now().subtract(const Duration(days: 365))
            : records.sortedBy((r) => r.examStartedTime).first.examStartedTime)
        .toDate();
  }

  DateTime getDefaultEndDate({List<ExamRecord>? records}) {
    records ??= originalRecords;
    if (records.isEmpty) {
      return DateTime.now();
    }

    final DateTime lastTime =
        records.sortedBy((r) => r.examStartedTime).last.examStartedTime;
    return lastTime.isAfter(DateTime.now())
        ? lastTime.toDate()
        : DateTime.now().toDate();
  }

  DateTimeRange get defaultDateRange =>
      DateTimeRange(start: getDefaultStartDate(), end: getDefaultEndDate());
}
