import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem.freezed.dart';
part 'problem.g.dart';

@freezed
class WrongProblem with _$WrongProblem {
  const factory WrongProblem(int problemNumber) = _WrongProblem;

  factory WrongProblem.fromJson(Map<String, dynamic> json) => _$WrongProblemFromJson(json);

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

  ReviewProblem({required this.title, this.memo = '', this.imagePaths = const []});

  factory ReviewProblem.fromJson(Map<String, dynamic> json) => _$ReviewProblemFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewProblemToJson(this);

  @override
  String toString() {
    return 'ReviewProblem{title: $title, memo: $memo, imagePaths: $imagePaths}';
  }
}
