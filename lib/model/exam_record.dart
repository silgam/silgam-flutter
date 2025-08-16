import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import 'exam.dart';
import 'problem.dart';

part 'exam_record.freezed.dart';
part 'exam_record.g.dart';

@unfreezed
class ExamRecord with _$ExamRecord {
  const ExamRecord._();

  factory ExamRecord({
    required final String id,
    required final String userId,
    required final String title,
    @JsonKey(name: 'subject', toJson: Exam.toId, fromJson: Exam.fromId) required final Exam exam,
    required final DateTime examStartedTime,
    final int? examDurationMinutes,
    final int? score,
    final int? grade,
    final double? percentile,
    final int? standardScore,
    required final List<WrongProblem> wrongProblems,
    required final String feedback,
    required final List<ReviewProblem> reviewProblems,
    required final DateTime createdAt,
  }) = _ExamRecord;

  factory ExamRecord.create({
    required final String userId,
    required final String title,
    required final Exam exam,
    required final DateTime examStartedTime,
    final int? examDurationMinutes,
    final int? score,
    final int? grade,
    final double? percentile,
    final int? standardScore,
    final List<WrongProblem>? wrongProblems,
    final String? feedback,
    final List<ReviewProblem>? reviewProblems,
  }) => ExamRecord(
    id: '$userId-${const Uuid().v1()}',
    userId: userId,
    title: title,
    exam: exam,
    examStartedTime: examStartedTime,
    examDurationMinutes: examDurationMinutes,
    score: score,
    grade: grade,
    percentile: percentile,
    standardScore: standardScore,
    wrongProblems: wrongProblems ?? const [],
    feedback: feedback ?? '',
    reviewProblems: reviewProblems ?? const [],
    createdAt: DateTime.now().toUtc(),
  );

  factory ExamRecord.fromJson(Map<String, dynamic> json) => _$ExamRecordFromJson(json);

  static const String autoSaveTitlePrefix = '(자동 저장됨) ';

  int getGradeColor() {
    switch (grade) {
      case 1:
        return 0xFF7900D9;
      case 2:
        return 0xFF1D82CC;
      case 3:
        return 0xFF04A80B;
      case 4:
        return 0xFFFFA700;
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
        return 0xFFD60303;
      default:
        return 0xFF000000;
    }
  }
}
