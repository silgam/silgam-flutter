import 'package:json_annotation/json_annotation.dart';

part 'problem.g.dart';

@JsonSerializable()
class WrongProblem {
  final int problemNumber;

  WrongProblem(
    this.problemNumber,
  );

  factory WrongProblem.fromJson(Map<String, dynamic> json) => _$WrongProblemFromJson(json);

  Map<String, dynamic> toJson() => _$WrongProblemToJson(this);

  static List<Map<String, dynamic>> toJsonList(List<WrongProblem> instances) {
    return instances.map((e) => e.toJson()).toList();
  }

  @override
  String toString() {
    return 'WrongProblem{problemNumber: $problemNumber}';
  }
}

@JsonSerializable()
class ReviewProblem {
  final String title;
  final String memo;
  final List<String> imagePaths;

  ReviewProblem({
    required this.title,
    this.memo = '',
    this.imagePaths = const [],
  });

  factory ReviewProblem.fromJson(Map<String, dynamic> json) => _$ReviewProblemFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewProblemToJson(this);

  static List<Map<String, dynamic>> toJsonList(List<ReviewProblem> instances) {
    return instances.map((e) => e.toJson()).toList();
  }

  @override
  String toString() {
    return 'ReviewProblem{title: $title, memo: $memo, imagePaths: $imagePaths}';
  }
}
