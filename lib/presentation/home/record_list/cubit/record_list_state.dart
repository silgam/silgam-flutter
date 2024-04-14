part of 'record_list_cubit.dart';

@freezed
class RecordListState with _$RecordListState {
  const RecordListState._();

  const factory RecordListState({
    @Default(false) bool isLoading,
    @Default([]) List<ExamRecord> originalRecords,
    @Default([]) List<ExamRecord> records,
    @Default('') String searchQuery,
    @Default(RecordSortType.dateDesc) RecordSortType sortType,
    @Default([]) List<Exam> selectedExams,
  }) = _RecordListState;

  factory RecordListState.initial() {
    return const RecordListState();
  }
}
