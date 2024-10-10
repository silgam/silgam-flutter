import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/announcement.dart';
import '../../../model/exam.dart';
import '../../../model/exam_detail.dart';
import '../../../model/lap_time.dart';
import '../../../util/date_time_extension.dart';
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
        lapTimes: _examDetail.lapTimes.sortedBy((lapTime) => lapTime.time),
      );
    } else {
      _updateLapTimeItemGroupsUsingExample();
    }
  }

  void examRecorded(Exam exam, String recordId) {
    emit(state.copyWith(
      examToRecordIds: {...state.examToRecordIds, exam: recordId},
    ));
  }

  void examRecordDeleted(Exam exam) {
    emit(state.copyWith(
      examToRecordIds: {...state.examToRecordIds}..remove(exam),
    ));
  }

  void _updateLapTimeItemGroups({required List<LapTime> lapTimes}) {
    final Map<Exam, List<LapTimeItemGroup>> examToLapTimeItemGroups = {};

    for (final lapTime in lapTimes) {
      final exam = lapTime.breakpoint.exam;

      final List<LapTimeItemGroup> lapTimeItemGroups =
          examToLapTimeItemGroups.putIfAbsent(exam, () => []);

      final Announcement? targetAnnouncement;
      if (lapTime.time.isSameOrAfter(exam.endTime)) {
        targetAnnouncement = exam.finishAnnouncement;
      } else if (lapTime.time.isSameOrAfter(exam.startTime)) {
        targetAnnouncement = exam.startAnnouncement;
      } else {
        targetAnnouncement = exam.firstAnnouncement;
      }

      if (targetAnnouncement != null &&
          lapTimeItemGroups.lastOrNull?.announcementPurpose !=
              targetAnnouncement.purpose) {
        lapTimeItemGroups.add(LapTimeItemGroup(
          title: targetAnnouncement.title,
          startTime: targetAnnouncement.time.calculateBreakpointTime(
            exam.startTime,
            exam.endTime,
          ),
          announcementPurpose: targetAnnouncement.purpose,
          lapTimeItems: [],
        ));
      }

      final lapTimeItemGroup = lapTimeItemGroups.last;
      lapTimeItemGroup.lapTimeItems.add(LapTimeItem(
        time: lapTime.time,
        timeDifference: lapTime.time.difference(
          lapTimeItemGroup.lapTimeItems.lastOrNull?.time ??
              lapTimeItemGroup.startTime,
        ),
        timeElapsed: lapTime.time.difference(lapTimeItemGroup.startTime),
      ));
    }

    emit(state.copyWith(
      examToLapTimeItemGroups: examToLapTimeItemGroups,
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
      examToLapTimeItemGroups: {firstExam: exampleLapTimeItemGroups},
      isUsingExampleLapTimeItemGroups: true,
    ));
  }
}
