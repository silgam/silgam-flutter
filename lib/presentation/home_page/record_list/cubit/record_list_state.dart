part of 'record_list_cubit.dart';

@freezed
class RecordListState with _$RecordListState {
  const RecordListState._();

  const factory RecordListState({
    required bool isLoading,
    required List<ExamRecord> originalRecords,
    required List<ExamRecord> records,
    required List<String> lockedRecordIds,
    required String searchQuery,
    required RecordSortType sortType,
    required List<Subject> selectedSubjects,
  }) = _RecordListState;

  factory RecordListState.initial() {
    return const RecordListState(
      isLoading: false,
      originalRecords: [],
      records: [],
      lockedRecordIds: [],
      searchQuery: '',
      sortType: RecordSortType.dateDesc,
      selectedSubjects: [],
    );
  }
}
