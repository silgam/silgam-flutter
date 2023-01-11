part of 'record_list_cubit.dart';

@freezed
class RecordListState with _$RecordListState {
  const RecordListState._();

  const factory RecordListState({
    required User? me,
    required bool isLoading,
    required List<ExamRecord> originalRecords,
    required List<ExamRecord> records,
    required String searchQuery,
    required RecordSortType sortType,
    required List<Subject> selectedSubjects,
  }) = _RecordListState;

  factory RecordListState.initial() {
    return const RecordListState(
      me: null,
      isLoading: false,
      originalRecords: [],
      records: [],
      searchQuery: '',
      sortType: RecordSortType.dateDesc,
      selectedSubjects: [],
    );
  }

  bool get isSignedIn => me != null;
  bool get isNotSignedIn => me == null;
}
