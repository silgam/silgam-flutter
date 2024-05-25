import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../model/exam.dart';
import '../../../repository/exam/exam_repository.dart';
import '../../../util/date_time_extension.dart';
import '../../app/cubit/app_cubit.dart';

part 'custom_exam_edit_cubit.freezed.dart';
part 'custom_exam_edit_state.dart';

class CustomExamEditCubit extends Cubit<CustomExamEditState> {
  CustomExamEditCubit(this._examRepository, this._appCubit)
      : super(const CustomExamEditState.initial());

  final ExamRepository _examRepository;
  final AppCubit _appCubit;

  void save({
    required String examName,
    required Exam baseExam,
    required TimeOfDay startTime,
    required int duration,
    required int numberOfQuestions,
    required int perfectScore,
  }) {
    final userId = _appCubit.state.me!.id;
    final newExam = Exam(
      id: '$userId-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      subject: baseExam.subject,
      name: examName,
      number: baseExam.number,
      startTime: startTime.toDateTime(),
      durationMinutes: duration,
      numberOfQuestions: numberOfQuestions,
      perfectScore: perfectScore,
      color: baseExam.color,
      createdAt: DateTime.now(),
    );
    _examRepository.addExam(newExam);
  }
}
