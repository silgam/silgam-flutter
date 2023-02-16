import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../model/exam_record.dart';
import '../../../../model/subject.dart';
import '../../../../util/analytics_manager.dart';
import '../../../../util/injection.dart';
import '../../../app/cubit/app_cubit.dart';
import '../../record_list/cubit/record_list_cubit.dart';
import '../stat_view.dart';

part 'stat_cubit.freezed.dart';
part 'stat_state.dart';

@lazySingleton
class StatCubit extends Cubit<StatState> {
  StatCubit() : super(StatState.initial());

  final AppCubit _appCubit = getIt.get();
  final RecordListCubit _recordListCubit = getIt.get();

  void onOriginalRecordsUpdated(List<ExamRecord> records) {
    emit(state.copyWith(originalRecords: records));
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    if (_appCubit.state.isNotSignedIn) {
      emit(StatState.initial());
      return;
    }

    AnalyticsManager.logEvent(name: '[HomePage-stat] Refresh');

    emit(state.copyWith(isLoading: true));
    await _recordListCubit.refresh();
    emit(state.copyWith(isLoading: false));
  }

  void onSubjectFilterButtonTapped(Subject subject) {
    final selectedSubjects = [...state.selectedSubjects];
    if (selectedSubjects.contains(subject)) {
      selectedSubjects.remove(subject);
    } else {
      selectedSubjects.add(subject);
    }
    emit(state.copyWith(selectedSubjects: selectedSubjects));

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
}
