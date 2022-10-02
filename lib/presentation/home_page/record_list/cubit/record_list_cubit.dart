import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../model/exam_record.dart';
import '../../../../repository/exam_record_repository.dart';
import '../../../../repository/user_repository.dart';

part 'record_list_cubit.freezed.dart';
part 'record_list_state.dart';

class RecordListCubit extends Cubit<RecordListState> {
  RecordListCubit() : super(const RecordListState.initial());
  final ExamRecordRepository _recordRepository = ExamRecordRepository();
  final UserRepository _userRepository = UserRepository();

  List<ExamRecord> _records = [];

  Future<void> refresh() async {
    if (_userRepository.isNotSignedIn()) {
      emit(const RecordListNotSignedIn());
      return;
    }
    if (state is RecordListLoading) return;

    emit(RecordListLoading(records: _records));
    _records = await _recordRepository.getMyExamRecords();
    emit(RecordListLoaded(records: _records));
  }

  void onSearchTextChanged(String query) {
    final filteredRecords = _records.where(
      (exam) => exam.title.contains(query) || exam.feedback.contains(query),
    );
    emit(RecordListLoaded(records: filteredRecords.toList()));
  }
}
