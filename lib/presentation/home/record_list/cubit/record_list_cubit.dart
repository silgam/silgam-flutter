import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../model/exam.dart';
import '../../../../model/exam_record.dart';
import '../../../../repository/exam_record/exam_record_repository.dart';
import '../../../../util/analytics_manager.dart';
import '../../../app/cubit/app_cubit.dart';
import '../record_list_view.dart';

part 'record_list_cubit.freezed.dart';
part 'record_list_state.dart';

@lazySingleton
class RecordListCubit extends Cubit<RecordListState> {
  RecordListCubit(this._examRecordRepository, this._appCubit)
      : super(RecordListState.initial()) {
    refresh();
  }

  final ExamRecordRepository _examRecordRepository;
  final AppCubit _appCubit;

  Future<void> refresh() async {
    if (state.isLoading) return;
    if (_appCubit.state.isNotSignedIn) {
      emit(RecordListState.initial());
      return;
    }

    AnalyticsManager.logEvent(name: '[HomePage-list] Refresh');

    emit(state.copyWith(isLoading: true));

    final records =
        await _examRecordRepository.getMyExamRecords(_appCubit.state.me!.id);
    final filteredRecords =
        _getFilteredAndSortedRecords(originalRecords: records);

    emit(state.copyWith(
      isLoading: false,
      originalRecords: records,
      records: filteredRecords,
    ));

    AnalyticsManager.setPeopleProperty(
        'Number of Exam Records', records.length);
  }

  Future<void> onRecordCreated(ExamRecord record) async {
    final newOriginalRecords = [...state.originalRecords, record];
    emit(state.copyWith(
      originalRecords: newOriginalRecords,
      records: _getFilteredAndSortedRecords(
        originalRecords: newOriginalRecords,
      ),
    ));
    await refresh();
  }

  Future<void> onRecordUpdated(ExamRecord record) async {
    final newOriginalRecords = [
      ...state.originalRecords.where((r) => r.id != record.id),
      record
    ];
    emit(state.copyWith(
      originalRecords: newOriginalRecords,
      records: _getFilteredAndSortedRecords(
        originalRecords: newOriginalRecords,
      ),
    ));
    await refresh();
  }

  Future<void> onRecordDeleted(ExamRecord record) async {
    final newOriginalRecords =
        state.originalRecords.where((r) => r.id != record.id).toList();
    emit(state.copyWith(
      originalRecords: newOriginalRecords,
      records: _getFilteredAndSortedRecords(
        originalRecords: newOriginalRecords,
      ),
    ));
    await refresh();
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

  void onExamFilterButtonTapped(Exam exam) {
    final selectedExams = [...state.selectedExams];
    if (selectedExams.contains(exam)) {
      selectedExams.remove(exam);
    } else {
      selectedExams.add(exam);
    }
    final records = _getFilteredAndSortedRecords(selectedExams: selectedExams);
    emit(state.copyWith(selectedExams: selectedExams, records: records));

    AnalyticsManager.logEvent(
      name: '[HomePage-list] Exam filter button tapped',
      properties: {
        'subject': exam.subject.name,
        'examId': exam.id,
        'selected': state.selectedExams.contains(exam),
      },
    );
  }

  void onFilterResetButtonTapped() {
    final records = _getFilteredAndSortedRecords(
      sortType: RecordSortType.dateDesc,
      selectedExams: [],
    );
    emit(state.copyWith(
      sortType: RecordSortType.dateDesc,
      selectedExams: [],
      records: records,
    ));

    AnalyticsManager.logEvent(
        name: '[HomePage-list] Filter reset button tapped');
  }

  List<ExamRecord> _getFilteredAndSortedRecords({
    List<ExamRecord>? originalRecords,
    String? searchQuery,
    RecordSortType? sortType,
    List<Exam>? selectedExams,
  }) {
    originalRecords ??= state.originalRecords;
    searchQuery ??= state.searchQuery;
    sortType ??= state.sortType;
    selectedExams ??= state.selectedExams;

    return originalRecords.where(
      (record) {
        if (searchQuery!.isEmpty) return true;
        return record.title.contains(searchQuery) ||
            record.feedback.contains(searchQuery);
      },
    ).where((record) {
      if (selectedExams!.isEmpty) return true;
      return selectedExams.contains(record.exam);
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
