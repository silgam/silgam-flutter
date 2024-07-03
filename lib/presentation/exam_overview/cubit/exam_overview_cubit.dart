import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/exam.dart';
import '../../../model/exam_detail.dart';
import '../../../model/lap_time.dart';
import '../../app/cubit/app_cubit.dart';
import '../example_lap_time_groups.dart';

part 'exam_overview_cubit.freezed.dart';
part 'exam_overview_state.dart';

@injectable
class ExamOverviewCubit extends Cubit<ExamOverviewState> {
  ExamOverviewCubit(
    @factoryParam this._examDetail,
    this._appCubit,
  ) : super(const ExamOverviewState()) {
    initialize();
  }

  final ExamDetail _examDetail;
  final AppCubit _appCubit;

  void initialize() {
    if (_appCubit.state.productBenefit.isLapTimeAvailable) {
      _updateLapTimeItemGroups(
        exams: _examDetail.exams,
        lapTimes: _examDetail.lapTimes.sortedBy((lapTime) => lapTime.time),
      );
    } else {
      _updateLapTimeItemGroupsUsingExample();
    }
  }

  void examRecorded(String examId) {
    emit(state.copyWith(
      recordedExamIds: {...state.recordedExamIds, examId},
    ));
  }

  void _updateLapTimeItemGroups({
    required List<Exam> exams,
    required List<LapTime> lapTimes,
  }) {
    final List<LapTimeItemGroup> lapTimeItemGroups = [];
    for (final exam in exams) {
      for (final announcement in exam.subject.defaultAnnouncements) {
        if (announcement.title.contains('예비령')) {
          lapTimeItemGroups.add(LapTimeItemGroup(
            title: announcement.title,
            startTime: announcement.time.calculateBreakpointTime(
              exam.startTime,
              exam.endTime,
            ),
            lapTimeItems: [],
          ));
        } else if (announcement.title.contains('본령')) {
          lapTimeItemGroups.add(LapTimeItemGroup(
            title: announcement.title,
            startTime: announcement.time.calculateBreakpointTime(
              exam.startTime,
              exam.endTime,
            ),
            lapTimeItems: [],
          ));
        }
      }
    }

    lapTimeItemGroups.forEachIndexed((index, group) {
      final lapTimesForGroup = lapTimes
          .where(
            (lapTime) =>
                (lapTime.time.isAfter(group.startTime) ||
                    lapTime.time.isAtSameMomentAs(group.startTime)) &&
                (index == lapTimeItemGroups.length - 1
                    ? true
                    : lapTime.time
                        .isBefore(lapTimeItemGroups[index + 1].startTime)),
          )
          .toList();
      final lapTimeItems = lapTimesForGroup.mapIndexed(
        (index, lapTime) {
          final timeDifference = index == 0
              ? lapTime.time.difference(group.startTime)
              : lapTime.time.difference(lapTimesForGroup[index - 1].time);
          final timeElapsed = lapTime.time.difference(group.startTime);
          return LapTimeItem(
            time: lapTime.time,
            timeDifference: timeDifference,
            timeElapsed: timeElapsed,
          );
        },
      ).toList();
      lapTimeItemGroups[index] = group.copyWith(
        lapTimeItems: lapTimeItems,
      );
    });

    lapTimeItemGroups.removeWhere((group) => group.lapTimeItems.isEmpty);

    emit(state.copyWith(
      lapTimeItemGroups: lapTimeItemGroups,
    ));
  }

  void _updateLapTimeItemGroupsUsingExample() {
    final firstExam = _examDetail.exams.first;
    final exampleLapTimeItemGroups = getExampleLapTimeGroups(
      startTime: firstExam.subject.defaultAnnouncements.first.time
          .calculateBreakpointTime(
        firstExam.startTime,
        firstExam.endTime,
      ),
    );

    emit(state.copyWith(
      lapTimeItemGroups: exampleLapTimeItemGroups,
      isUsingExampleLapTimeItemGroups: true,
    ));
  }
}
