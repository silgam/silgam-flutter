import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../model/exam.dart';
import '../../../../model/exam_record.dart';
import '../../../../util/analytics_manager.dart';
import '../../../../util/date_time_extension.dart';
import '../../../../util/injection.dart';
import '../../../app/cubit/app_cubit.dart';
import '../../record_list/cubit/record_list_cubit.dart';
import '../example_records.dart';
import '../stat_view.dart';

part 'stat_cubit.freezed.dart';
part 'stat_state.dart';

@lazySingleton
class StatCubit extends Cubit<StatState> {
  StatCubit() : super(StatState.initial());

  final AppCubit _appCubit = getIt.get();
  final RecordListCubit _recordListCubit = getIt.get();

  late final _exampleRecords = getExampleRecords();

  void onOriginalRecordsUpdated() {
    var recordsToShow = _appCubit.state.productBenefit.isStatisticAvailable
        ? _recordListCubit.state.originalRecords
        : _exampleRecords;
    recordsToShow = recordsToShow.sortedBy((record) => record.examStartedTime);
    final dateRange = DateTimeRange(
      start: state.isDateRangeSet
          ? state.dateRange.start
          : state.getDefaultStartDate(records: recordsToShow),
      end: state.isDateRangeSet
          ? state.dateRange.end
          : state.getDefaultEndDate(records: recordsToShow),
    );

    emit(state.copyWith(
      originalRecords: recordsToShow,
      records: _getFilteredRecords(
        originalRecords: recordsToShow,
        dateRange: dateRange,
      ),
      dateRange: dateRange,
    ));
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    if (_appCubit.state.isNotSignedIn) {
      emit(StatState.initial());
      onOriginalRecordsUpdated();
      return;
    }

    AnalyticsManager.logEvent(name: '[HomePage-stat] Refresh');

    emit(state.copyWith(isLoading: true));
    await _recordListCubit.refresh();
    emit(state.copyWith(isLoading: false));
  }

  void onSearchTextChanged(String query) {
    emit(state.copyWith(
      searchQuery: query,
      records: _getFilteredRecords(searchQuery: query),
    ));
  }

  void onExamFilterButtonTapped(Exam exam) {
    final selectedExams = [...state.selectedExams];
    if (selectedExams.contains(exam)) {
      selectedExams.remove(exam);
    } else {
      selectedExams.add(exam);
    }
    emit(state.copyWith(
      selectedExams: selectedExams,
      records: _getFilteredRecords(selectedExams: selectedExams),
    ));

    AnalyticsManager.logEvent(
      name: '[HomePage-stat] Exam filter button tapped',
      properties: {
        'subject': exam.subject.name,
        'examId': exam.id,
        'selected': state.selectedExams.contains(exam),
      },
    );
  }

  void onFilterResetButtonTapped() {
    emit(state.copyWith(
      selectedExams: [],
      isDateRangeSet: false,
      dateRange: state.defaultDateRange,
      records: _getFilteredRecords(
        selectedExams: [],
        dateRange: state.defaultDateRange,
      ),
    ));

    AnalyticsManager.logEvent(
        name: '[HomePage-stat] Filter reset button tapped');
  }

  void onDateRangeChanged(DateTimeRange dateRange) {
    if (dateRange == state.dateRange) return;

    emit(state.copyWith(
      isDateRangeSet: dateRange != state.defaultDateRange,
      dateRange: dateRange,
      records: _getFilteredRecords(
        dateRange: dateRange,
      ),
    ));

    AnalyticsManager.logEvent(
      name: '[HomePage-stat] Date range changed',
      properties: {
        'start_date': dateRange.start.toString(),
        'end_date': dateRange.end.toString(),
      },
    );
  }

  void onExamValueTypeChanged(ExamValueType? examValueType) {
    if (examValueType == null) return;
    emit(state.copyWith(selectedExamValueType: examValueType));

    AnalyticsManager.logEvent(
      name: '[HomePage-stat] Exam value type changed',
      properties: {
        'exam_value_type': examValueType.name,
      },
    );
  }

  Map<Exam, List<ExamRecord>> _getFilteredRecords({
    List<ExamRecord>? originalRecords,
    String? searchQuery,
    List<Exam>? selectedExams,
    DateTimeRange? dateRange,
  }) {
    originalRecords ??= state.originalRecords;
    searchQuery ??= state.searchQuery;
    selectedExams ??= state.selectedExams;
    dateRange ??= state.dateRange;

    var records = [...originalRecords];
    if (searchQuery.isNotEmpty) {
      records = records
          .where((record) => record.title.contains(searchQuery!))
          .toList();
    }
    records = records
        .where(
          (record) =>
              record.examStartedTime.isSameOrAfter(dateRange!.start) &&
              record.examStartedTime.isBefore(
                dateRange.end.add(const Duration(days: 1)),
              ),
        )
        .toList();
    final Map<Exam, List<ExamRecord>> filteredRecords =
        records.groupListsBy((record) => record.exam)
          ..removeWhere(
            (exam, records) =>
                records.isEmpty ||
                (selectedExams!.isNotEmpty && !selectedExams.contains(exam)),
          );
    return filteredRecords;
  }
}
