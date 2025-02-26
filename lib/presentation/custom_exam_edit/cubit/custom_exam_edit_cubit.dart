import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/exam.dart';
import '../../../repository/exam/exam_repository.dart';
import '../../../util/date_time_extension.dart';
import '../../app/cubit/app_cubit.dart';

part 'custom_exam_edit_cubit.freezed.dart';
part 'custom_exam_edit_state.dart';

@injectable
class CustomExamEditCubit extends Cubit<CustomExamEditState> {
  CustomExamEditCubit(this._examRepository, this._appCubit)
    : super(const CustomExamEditState.initial());

  final ExamRepository _examRepository;
  final AppCubit _appCubit;

  void save({
    required Exam? examToEdit,
    required String examName,
    required Exam baseExam,
    required TimeOfDay startTime,
    required int duration,
    required int numberOfQuestions,
    required int perfectScore,
    required bool isBeforeFinishAnnouncementEnabled,
  }) {
    final userId = _appCubit.state.me!.id;
    final newExam = Exam(
      id: examToEdit?.id ?? '$userId-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      subject: baseExam.subject,
      name: examName,
      number: baseExam.number,
      startTime: startTime.toDateTime(),
      durationMinutes: duration,
      numberOfQuestions: numberOfQuestions,
      perfectScore: perfectScore,
      isBeforeFinishAnnouncementEnabled: isBeforeFinishAnnouncementEnabled,
      color: baseExam.color,
      createdAt: examToEdit?.createdAt ?? DateTime.now(),
    );

    if (examToEdit == null) {
      _examRepository.addExam(newExam);
    } else {
      _examRepository.updateExam(newExam);
    }
  }
}
