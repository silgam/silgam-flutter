import '../repository/exam_repository.dart';

enum Subject {
  language(
    subjectName: '국어',
    firstColor: 0xFF55B99E,
    secondColor: 0xFF68D69B,
  ),
  math(
    subjectName: '수학',
    firstColor: 0xFFE05FA9,
    secondColor: 0xFFF574DD,
  ),
  english(
    subjectName: '영어',
    firstColor: 0xFF0098C3,
    secondColor: 0xFF03BAEB,
  ),
  history(
    subjectName: '한국사',
    firstColor: 0xFF7B4DB9,
    secondColor: 0xFF8F6CE0,
  ),
  investigation(
    subjectName: '탐구1',
    firstColor: 0xFF7B4DB9,
    secondColor: 0xFF8F6CE0,
  ),
  investigation2(
    subjectName: '탐구2',
    firstColor: 0xFF7B4DB9,
    secondColor: 0xFF8F6CE0,
  ),
  secondLanguage(
    subjectName: '제2외국어/한문',
    firstColor: 0xFFF39328,
    secondColor: 0xFFF7B061,
  );

  const Subject({
    required this.subjectName,
    required this.firstColor,
    required this.secondColor,
  });

  final String subjectName;
  final int firstColor;
  final int secondColor;

  int get defaultExamDuration {
    final defaultExam = ExamRepository.defaultExams.firstWhere((exam) {
      if (this == Subject.investigation2) {
        return exam.subject == Subject.investigation;
      }
      return exam.subject == this;
    });
    if (this == Subject.investigation || this == Subject.investigation2) {
      return 30;
    } else {
      return defaultExam.examDuration;
    }
  }
}
