// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamRecord _$ExamRecordFromJson(Map<String, dynamic> json) => ExamRecord(
      userId: json['userId'] as String,
      title: json['title'] as String,
      subject: $enumDecode(_$SubjectEnumMap, json['subject']),
      examStartedTime: DateTime.parse(json['examStartedTime'] as String),
      examDurationMinutes: json['examDurationMinutes'] as int?,
      score: json['score'] as int?,
      grade: json['grade'] as int?,
      wrongProblems: (json['wrongProblems'] as List<dynamic>?)
              ?.map((e) => WrongProblem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      feedback: json['feedback'] as String? ?? '',
      reviewProblems: (json['reviewProblems'] as List<dynamic>?)
              ?.map((e) => ReviewProblem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExamRecordToJson(ExamRecord instance) => <String, dynamic>{
      'userId': instance.userId,
      'title': instance.title,
      'subject': _$SubjectEnumMap[instance.subject],
      'examStartedTime': instance.examStartedTime.toIso8601String(),
      'examDurationMinutes': instance.examDurationMinutes,
      'score': instance.score,
      'grade': instance.grade,
      'wrongProblems': WrongProblem.toJsonList(instance.wrongProblems),
      'feedback': instance.feedback,
      'reviewProblems': ReviewProblem.toJsonList(instance.reviewProblems),
    };

const _$SubjectEnumMap = {
  Subject.language: 'language',
  Subject.math: 'math',
  Subject.english: 'english',
  Subject.history: 'history',
  Subject.investigation: 'investigation',
  Subject.secondLanguage: 'secondLanguage',
};
