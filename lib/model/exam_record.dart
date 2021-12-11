import 'problem.dart';
import 'subject.dart';

class ExamRecord {
  final String title;
  final Subject subject;
  final DateTime examStartedTime;
  final int? examDurationMinutes;
  final int? score;
  final int? grade;
  final List<WrongProblem> wrongProblems;
  final String? feedback;
  final List<ReviewProblem> reviewProblems;

  ExamRecord({
    required this.title,
    required this.subject,
    required this.examStartedTime,
    this.examDurationMinutes,
    this.score,
    this.grade,
    this.wrongProblems = const [],
    this.feedback,
    this.reviewProblems = const [],
  });
}
