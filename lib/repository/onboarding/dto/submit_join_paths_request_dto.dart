import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_join_paths_request_dto.freezed.dart';
part 'submit_join_paths_request_dto.g.dart';

@freezed
class SubmitJoinPathsRequestDto with _$SubmitJoinPathsRequestDto {
  const factory SubmitJoinPathsRequestDto({
    required List<String> joinPathIds,
    required String? userId,
    required String? otherJoinPath,
    required bool isSkipped,
  }) = _SubmitJoinPathsRequestDto;

  factory SubmitJoinPathsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitJoinPathsRequestDtoFromJson(json);
}
