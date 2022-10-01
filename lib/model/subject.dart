import '../repository/exam_repository.dart';

enum Subject {
  language,
  math,
  english,
  history,
  investigation,
  investigation2,
  secondLanguage,
}

extension SubjectExtension on Subject {
  String get subjectName {
    switch (this) {
      case Subject.language:
        return '국어';
      case Subject.math:
        return '수학';
      case Subject.english:
        return '영어';
      case Subject.history:
        return '한국사';
      case Subject.investigation:
        return '탐구1';
      case Subject.investigation2:
        return '탐구2';
      case Subject.secondLanguage:
        return '제2외국어/한문';
    }
  }

  int get firstColor {
    switch (this) {
      case Subject.language:
        return 0xFF55B99E;
      case Subject.math:
        return 0xFFE05FA9;
      case Subject.english:
        return 0xFF0098C3;
      case Subject.history:
        return 0xFF7B4DB9;
      case Subject.investigation:
        return 0xFF7B4DB9;
      case Subject.investigation2:
        return 0xFF7B4DB9;
      case Subject.secondLanguage:
        return 0xFFF39328;
    }
  }

  int get secondColor {
    switch (this) {
      case Subject.language:
        return 0xFF68D69B;
      case Subject.math:
        return 0xFFF574DD;
      case Subject.english:
        return 0xFF03BAEB;
      case Subject.history:
        return 0xFF8F6CE0;
      case Subject.investigation:
        return 0xFF8F6CE0;
      case Subject.investigation2:
        return 0xFF8F6CE0;
      case Subject.secondLanguage:
        return 0xFFF7B061;
    }
  }

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
