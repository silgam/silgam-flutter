import 'package:freezed_annotation/freezed_annotation.dart';

import 'problem.dart';
import 'subject.dart';

part 'exam_record.freezed.dart';
part 'exam_record.g.dart';

@unfreezed
class ExamRecord with _$ExamRecord {
  const ExamRecord._();

  factory ExamRecord({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String documentId,
    required final String userId,
    required final String title,
    required final Subject subject,
    required final DateTime examStartedTime,
    final int? examDurationMinutes,
    final int? score,
    final int? grade,
    final int? percentile,
    final int? standardScore,
    @JsonKey(toJson: WrongProblem.toJsonList)
    required final List<WrongProblem> wrongProblems,
    required final String feedback,
    @JsonKey(toJson: ReviewProblem.toJsonList)
    required final List<ReviewProblem> reviewProblems,
  }) = _ExamRecord;

  factory ExamRecord.fromJson(Map<String, dynamic> json) =>
      _$ExamRecordFromJson(json);

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
