import 'package:freezed_annotation/freezed_annotation.dart';

import '../repository/exam/exam_repository.dart';

enum Subject {
  @JsonValue('language')
  language(
    firstColor: 0xFF55B99E,
    secondColor: 0xFF3B8F78,
  ),
  @JsonValue('math')
  math(
    firstColor: 0xFFE05FA9,
    secondColor: 0xFFD83492,
  ),
  @JsonValue('english')
  english(
    firstColor: 0xFF0098C3,
    secondColor: 0xFF0080A5,
  ),
  @JsonValue('history')
  history(
    firstColor: 0xFF714925,
    secondColor: 0xFFAE7036,
  ),
  @JsonValue('investigation')
  investigation(
    firstColor: 0xFF7B4DB9,
    secondColor: 0xFF633C97,
  ),
  @JsonValue('investigation2')
  investigation2(
    firstColor: 0xFF3331A3,
    secondColor: 0xFF5552CE,
  ),
  @JsonValue('secondLanguage')
  secondLanguage(
    firstColor: 0xFFF39328,
    secondColor: 0xFFDC7A0C,
  );

  const Subject({
    required this.firstColor,
    required this.secondColor,
  });

  static const Map<Subject, String> defaultSubjectNameMap = {
    Subject.language: '국어',
    Subject.math: '수학',
    Subject.english: '영어',
    Subject.history: '한국사',
    Subject.investigation: '탐구1',
    Subject.investigation2: '탐구2',
    Subject.secondLanguage: '제2외국어/한문',
  };
  static Map<Subject, String> subjectNameMap = defaultSubjectNameMap;

  final int firstColor;
  final int secondColor;

  String get subjectName => subjectNameMap[this] ?? '';

  int get defaultExamDuration {
    final defaultExam = defaultExams.firstWhere((exam) {
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
