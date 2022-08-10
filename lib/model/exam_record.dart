import 'package:json_annotation/json_annotation.dart';

import 'problem.dart';
import 'subject.dart';

part 'exam_record.g.dart';

@JsonSerializable()
class ExamRecord {
  @JsonKey(ignore: true)
  String documentId;
  final String userId;
  final String title;
  final Subject subject;
  final DateTime examStartedTime;
  final int? examDurationMinutes;
  final int? score;
  final int? grade;
  final int? percentile;
  final int? standardScore;
  @JsonKey(toJson: WrongProblem.toJsonList)
  final List<WrongProblem> wrongProblems;
  final String feedback;
  @JsonKey(toJson: ReviewProblem.toJsonList)
  final List<ReviewProblem> reviewProblems;

  ExamRecord({
    this.documentId = '',
    required this.userId,
    required this.title,
    required this.subject,
    required this.examStartedTime,
    this.examDurationMinutes,
    this.score,
    this.grade,
    this.percentile,
    this.standardScore,
    this.wrongProblems = const [],
    this.feedback = '',
    this.reviewProblems = const [],
  });

  factory ExamRecord.fromJson(Map<String, dynamic> json) => _$ExamRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ExamRecordToJson(this);

  @override
  String toString() {
    return 'ExamRecord{documentId: $documentId, userId: $userId, title: $title, subject: $subject, examStartedTime: $examStartedTime, examDurationMinutes: $examDurationMinutes, score: $score, grade: $grade, percentile: $percentile, standardScore: $standardScore, wrongProblems: $wrongProblems, feedback: $feedback, reviewProblems: $reviewProblems}';
  }

  int getGradeColor() {
    switch (grade) {
      case 1:
        return 0xFF7201E2;
      case 2:
        return 0xFF1201E2;
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
