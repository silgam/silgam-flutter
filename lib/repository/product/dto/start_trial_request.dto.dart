import 'package:freezed_annotation/freezed_annotation.dart';

part 'start_trial_request.dto.freezed.dart';
part 'start_trial_request.dto.g.dart';

@freezed
class StartTrialRequestDto with _$StartTrialRequestDto {
  const factory StartTrialRequestDto({
    required String productId,
  }) = _StartTrialRequestDto;

  factory StartTrialRequestDto.fromJson(Map<String, dynamic> json) =>
      _$StartTrialRequestDtoFromJson(json);
}
