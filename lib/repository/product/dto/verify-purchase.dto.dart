import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify-purchase.dto.freezed.dart';
part 'verify-purchase.dto.g.dart';

@freezed
class VerifyPurchaseRequestDto with _$VerifyPurchaseRequestDto {
  const factory VerifyPurchaseRequestDto({
    required String productId,
    required String store,
    required String verificationToken,
  }) = _VerifyPurchaseRequestDto;

  factory VerifyPurchaseRequestDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyPurchaseRequestDtoFromJson(json);
}
