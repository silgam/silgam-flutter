import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/announcement.dart';
import '../../../model/exam.dart';
import '../../../model/exam_detail.dart';
import '../../../model/exam_record.dart';
import '../../../model/lap_time.dart';
import '../../../repository/exam_record/exam_record_repository.dart';
import '../../../util/const.dart';
import '../../../util/date_time_extension.dart';
import '../../../util/duration_extension.dart';
import '../../app/cubit/app_cubit.dart';
import '../../home/record_list/cubit/record_list_cubit.dart';
import '../example_lap_time_groups.dart';

part 'exam_overview_cubit.freezed.dart';
part 'exam_overview_state.dart';

@injectable
class ExamOverviewCubit extends Cubit<ExamOverviewState> {
  ExamOverviewCubit(
    @factoryParam this._examDetail,
    this._appCubit,
    this._recordListCubit,
    this._sharedPreferences,
    this._examRecordRepository,
  ) : super(const ExamOverviewState()) {
    updateLapTimeItemGroups();
    _autoSaveExamRecords();
  }

  final ExamDetail _examDetail;
  final AppCubit _appCubit;
  final RecordListCubit _recordListCubit;
  final SharedPreferences _sharedPreferences;
  final ExamRecordRepository _examRecordRepository;

  Future<void> _autoSaveExamRecords() async {
    // TODO: 저장 중일 때 로딩
    final userId = _appCubit.state.me?.id;
    if (userId == null) return;

    final isAutoSaveRecordsEnabled =
        _sharedPreferences.getBool(PreferenceKey.useAutoSaveRecords) ?? true;
    if (!isAutoSaveRecordsEnabled) return;

    // TODO: 기록 저장 가능 개수 제한 확인
    final List<ExamRecord> savedRecords = [];

    for (final exam in _examDetail.exams) {
      final examStartedTime = _examDetail.examStartedTimes[exam];
      final examFinishedTime = _examDetail.examFinishedTimes[exam];
      final examDurationMinutes = examStartedTime != null &&
              examFinishedTime != null
          ? examFinishedTime.difference(examStartedTime).inMinutesWithCorrection
          : exam.durationMinutes;

      final record = ExamRecord.create(
        userId: userId,
        title: ExamRecord.autoSaveTitlePrefix +
            (_examDetail.exams.length > 1
                ? '${_examDetail.timetableName} - '
                : '') +
            exam.name,
        exam: exam,
        examStartedTime: examStartedTime ?? DateTime.now(),
        examDurationMinutes: examDurationMinutes,
        feedback: state.getPrefillFeedbackForExamRecord(exam),
      );

      final savedRecord = await _examRecordRepository.addExamRecord(record);
      examRecorded(exam, savedRecord.id);
      savedRecords.add(savedRecord);
    }

    await _recordListCubit.onRecordsCreated(savedRecords);
  }

  void updateLapTimeItemGroups() {
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
