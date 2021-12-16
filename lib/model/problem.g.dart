// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WrongProblem _$WrongProblemFromJson(Map<String, dynamic> json) => WrongProblem(
      json['problemNumber'] as int,
    );

Map<String, dynamic> _$WrongProblemToJson(WrongProblem instance) => <String, dynamic>{
      'problemNumber': instance.problemNumber,
    };

ReviewProblem _$ReviewProblemFromJson(Map<String, dynamic> json) => ReviewProblem(
      title: json['title'] as String,
      memo: json['memo'] as String? ?? '',
      imagePaths: (json['imagePaths'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );

Map<String, dynamic> _$ReviewProblemToJson(ReviewProblem instance) => <String, dynamic>{
      'title': instance.title,
      'memo': instance.memo,
      'imagePaths': instance.imagePaths,
    };
