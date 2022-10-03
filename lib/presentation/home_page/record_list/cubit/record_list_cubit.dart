import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../model/exam_record.dart';
import '../../../../model/subject.dart';
import '../../../../repository/exam_record_repository.dart';
import '../../../../repository/user_repository.dart';

part 'record_list_cubit.freezed.dart';
part 'record_list_state.dart';

class RecordListCubit extends Cubit<RecordListState> {
  RecordListCubit() : super(RecordListState.initial());
  final ExamRecordRepository _recordRepository = ExamRecordRepository();
  final UserRepository _userRepository = UserRepository();

  Future<void> refresh() async {
    if (_userRepository.isNotSignedIn()) {
      emit(state.copyWith(isSignedIn: false));
      return;
    } else {
      emit(state.copyWith(isSignedIn: true));
    }
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));
    final records = await _recordRepository.getMyExamRecords();
    final filteredRecords = _getFilteredAndSortedRecords(originalRecords: records);
    emit(state.copyWith(isLoading: false, originalRecords: records, records: filteredRecords));
  }

  void onSearchTextChanged(String query) {
    final records = _getFilteredAndSortedRecords(searchQuery: query);
    emit(state.copyWith(searchQuery: query, records: records));
  }

  void onSortDateButtonTapped() {
    final records = _getFilteredAndSortedRecords(sortNewestFirst: !state.sortNewestFirst);
    emit(state.copyWith(sortNewestFirst: !state.sortNewestFirst, records: records));
  }

  void onSubjectFilterButtonTapped(Subject subject) {
    final selectedSubjects = [...state.selectedSubjects];
    if (selectedSubjects.contains(subject)) {
      selectedSubjects.remove(subject);
    } else {
      selectedSubjects.add(subject);
    }
    final records = _getFilteredAndSortedRecords(selectedSubjects: selectedSubjects);
    emit(state.copyWith(selectedSubjects: selectedSubjects, records: records));
  }

  void onFilterResetButtonTapped() {
    final records = _getFilteredAndSortedRecords(sortNewestFirst: true, selectedSubjects: []);
    emit(state.copyWith(sortNewestFirst: true, selectedSubjects: [], records: records));
  }

  List<ExamRecord> _getFilteredAndSortedRecords({
    List<ExamRecord>? originalRecords,
    String? searchQuery,
    bool? sortNewestFirst,
    List<Subject>? selectedSubjects,
  }) {
    originalRecords ??= state.originalRecords;
    searchQuery ??= state.searchQuery;
    sortNewestFirst ??= state.sortNewestFirst;
    selectedSubjects ??= state.selectedSubjects;

    return originalRecords.where(
      (exam) {
        if (searchQuery!.isEmpty) return true;
        return exam.title.contains(searchQuery) || exam.feedback.contains(searchQuery);
      },
    ).where((exam) {
      if (selectedSubjects!.isEmpty) return true;
      return selectedSubjects.contains(exam.subject);
    }).toList()
      ..sort((a, b) {
        if (sortNewestFirst!) {
          return b.examStartedTime.compareTo(a.examStartedTime);
        } else {
          return a.examStartedTime.compareTo(b.examStartedTime);
        }
      });
  }
}
