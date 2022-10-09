part of 'record_list_cubit.dart';

@freezed
class RecordListState with _$RecordListState {
  const factory RecordListState({
    required bool isSignedIn,
    required bool isLoading,
    required List<ExamRecord> originalRecords,
    required List<ExamRecord> records,
    required String searchQuery,
    required RecordSortType sortType,
    required List<Subject> selectedSubjects,
  }) = _RecordListState;

  factory RecordListState.initial() {
    return const RecordListState(
      isSignedIn: false,
      isLoading: false,
      originalRecords: [],
      records: [],
      searchQuery: '',
      sortType: RecordSortType.dateDesc,
      selectedSubjects: [],
    );
  }
}
