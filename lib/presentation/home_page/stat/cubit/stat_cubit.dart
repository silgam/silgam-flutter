import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../model/exam_record.dart';
import '../../../../model/subject.dart';
import '../../../../util/analytics_manager.dart';
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

  void onOriginalRecordsUpdated() {
    final recordsToShow = _appCubit.state.productBenefit.isStatisticAvailable
        ? _recordListCubit.state.records
        : exampleRecords;
    emit(state.copyWith(
      originalRecords: recordsToShow,
      records: _getFilteredRecords(originalRecords: recordsToShow),
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

  void onSubjectFilterButtonTapped(Subject subject) {
    final selectedSubjects = [...state.selectedSubjects];
    if (selectedSubjects.contains(subject)) {
      selectedSubjects.remove(subject);
    } else {
      selectedSubjects.add(subject);
    }
    emit(state.copyWith(
      selectedSubjects: selectedSubjects,
      records: _getFilteredRecords(selectedSubjects: selectedSubjects),
    ));

    AnalyticsManager.logEvent(
      name: '[HomePage-stat] Subject filter button tapped',
      properties: {
        'subject': subject.subjectName,
        'selected': state.selectedSubjects.contains(subject),
      },
    );
  }

  void onFilterResetButtonTapped() {
    emit(state.copyWith(
      selectedSubjects: [],
      records: _getFilteredRecords(selectedSubjects: []),
    ));

    AnalyticsManager.logEvent(
        name: '[HomePage-stat] Filter reset button tapped');
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

  Map<Subject, List<ExamRecord>> _getFilteredRecords({
    List<ExamRecord>? originalRecords,
    String? searchQuery,
    List<Subject>? selectedSubjects,
  }) {
    originalRecords ??= state.originalRecords;
    searchQuery ??= state.searchQuery;
    selectedSubjects ??= state.selectedSubjects;

    var records = [...originalRecords];
    if (searchQuery.isNotEmpty) {
      records = records
          .where((record) => record.title.contains(searchQuery!))
          .toList();
    }
    final Map<Subject, List<ExamRecord>> filteredRecords =
        records.groupListsBy((record) => record.subject)
          ..removeWhere(
            (subject, records) =>
                records.isEmpty ||
                (selectedSubjects!.isNotEmpty &&
                    !selectedSubjects.contains(subject)),
          );
    return filteredRecords;
  }
}
