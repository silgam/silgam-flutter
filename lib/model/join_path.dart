import 'package:freezed_annotation/freezed_annotation.dart';

part 'join_path.freezed.dart';
part 'join_path.g.dart';

@freezed
class JoinPath with _$JoinPath {
  const factory JoinPath({
    required String id,
    required String text,
    required String sectionTitle,
  }) = _JoinPath;

  factory JoinPath.fromJson(Map<String, dynamic> json) =>
      _$JoinPathFromJson(json);
}
