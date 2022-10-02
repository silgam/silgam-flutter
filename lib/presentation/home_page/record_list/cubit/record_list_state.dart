part of 'record_list_cubit.dart';

@freezed
class RecordListState with _$RecordListState {
  const factory RecordListState.initial() = RecordListInitial;
  const factory RecordListState.notSignedIn() = RecordListNotSignedIn;
  const factory RecordListState.loading({
    required List<ExamRecord> records,
  }) = RecordListLoading;
  const factory RecordListState.loaded({
    required List<ExamRecord> records,
  }) = RecordListLoaded;
}
