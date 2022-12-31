import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../model/exam_record.dart';
import '../../../../model/subject.dart';
import '../../../../repository/exam_record_repository.dart';
import '../../../../repository/user_repository.dart';
import '../../../../util/analytics_manager.dart';
import '../record_list_view.dart';

part 'record_list_cubit.freezed.dart';
part 'record_list_state.dart';

@injectable
class RecordListCubit extends Cubit<RecordListState> {
  RecordListCubit(
      ExamRecordRepository examRecordRepository, UserRepository userRepository)
      : _examRecordRepository = examRecordRepository,
        _userRepository = userRepository,
        super(RecordListState.initial());

  final ExamRecordRepository _examRecordRepository;
  final UserRepository _userRepository;

  Future<void> refresh() async {
    if (_userRepository.isNotSignedIn()) {
      emit(state.copyWith(isSignedIn: false));
      return;
    } else {
      emit(state.copyWith(isSignedIn: true));
    }
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));
    final records = await _examRecordRepository.getMyExamRecords();
    final filteredRecords =
        _getFilteredAndSortedRecords(originalRecords: records);
    emit(state.copyWith(
        isLoading: false, originalRecords: records, records: filteredRecords));

    AnalyticsManager.setPeopleProperty(
        'Number of Exam Records', records.length);
  }

  void onSearchTextChanged(String query) {
    final records = _getFilteredAndSortedRecords(searchQuery: query);
    emit(state.copyWith(searchQuery: query, records: records));
  }

  void onSortDateButtonTapped() {
    RecordSortType sortType = RecordSortType
        .values[(state.sortType.index + 1) % RecordSortType.values.length];
    final records = _getFilteredAndSortedRecords(sortType: sortType);
    emit(state.copyWith(sortType: sortType, records: records));

    AnalyticsManager.logEvent(
      name: '[HomePage-list] Sort-by-date button tapped',
      properties: {
        'sort_newest_first': state.sortType.name,
      },
    );
  }

  void onSubjectFilterButtonTapped(Subject subject) {
    final selectedSubjects = [...state.selectedSubjects];
    if (selectedSubjects.contains(subject)) {
      selectedSubjects.remove(subject);
    } else {
      selectedSubjects.add(subject);
    }
    final records =
        _getFilteredAndSortedRecords(selectedSubjects: selectedSubjects);
    emit(state.copyWith(selectedSubjects: selectedSubjects, records: records));

    AnalyticsManager.logEvent(
      name: '[HomePage-list] Subject filter button tapped',
      properties: {
        'subject': subject.subjectName,
        'selected': state.selectedSubjects.contains(subject),
      },
    );
  }

  void onFilterResetButtonTapped() {
    final records = _getFilteredAndSortedRecords(
        sortType: RecordSortType.dateDesc, selectedSubjects: []);
    emit(state.copyWith(
        sortType: RecordSortType.dateDesc,
        selectedSubjects: [],
        records: records));

    AnalyticsManager.logEvent(
        name: '[HomePage-list] Filter reset button tapped');
  }

  List<ExamRecord> _getFilteredAndSortedRecords({
    List<ExamRecord>? originalRecords,
    String? searchQuery,
    RecordSortType? sortType,
    List<Subject>? selectedSubjects,
  }) {
    originalRecords ??= state.originalRecords;
    searchQuery ??= state.searchQuery;
    sortType ??= state.sortType;
    selectedSubjects ??= state.selectedSubjects;

    return originalRecords.where(
      (exam) {
        if (searchQuery!.isEmpty) return true;
        return exam.title.contains(searchQuery) ||
            exam.feedback.contains(searchQuery);
      },
    ).where((exam) {
      if (selectedSubjects!.isEmpty) return true;
      return selectedSubjects.contains(exam.subject);
    }).toList()
      ..sort((a, b) {
        switch (sortType!) {
          case RecordSortType.dateDesc:
            return b.examStartedTime.compareTo(a.examStartedTime);
          case RecordSortType.dateAsc:
            return a.examStartedTime.compareTo(b.examStartedTime);
          case RecordSortType.titleAsc:
            return a.title.compareTo(b.title);
          case RecordSortType.titleDesc:
            return b.title.compareTo(a.title);
        }
      });
  }
}
