enum Subject {
  language,
  math,
  english,
  history,
  investigation,
  secondLanguage,
}

extension SubjectExtension on Subject {
  String get name {
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
        return '탐구';
      case Subject.secondLanguage:
        return '제2외국어/한문';
    }
  }

  int? get number {
    switch (this) {
      case Subject.language:
        return 1;
      case Subject.math:
        return 2;
      case Subject.english:
        return 3;
      case Subject.history:
        return 4;
      case Subject.investigation:
        return 4;
      case Subject.secondLanguage:
        return 5;
    }
  }
}
