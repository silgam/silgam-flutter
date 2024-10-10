import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_feedback_request.dto.freezed.dart';
part 'send_feedback_request.dto.g.dart';

@freezed
class SendFeedbackRequestDto with _$SendFeedbackRequestDto {
  const factory SendFeedbackRequestDto({
    required String? userId,
    required String feedback,
    required String appVersion,
    required String os,
    required String osVersion,
  }) = _SendFeedbackRequestDto;

  factory SendFeedbackRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SendFeedbackRequestDtoFromJson(json);
}
