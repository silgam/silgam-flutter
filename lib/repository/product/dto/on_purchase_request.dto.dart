import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_purchase_request.dto.freezed.dart';
part 'on_purchase_request.dto.g.dart';

@freezed
class OnPurchaseRequestDto with _$OnPurchaseRequestDto {
  const factory OnPurchaseRequestDto({
    required String productId,
    required String store,
    required String verificationToken,
  }) = _OnPurchaseRequestDto;

  factory OnPurchaseRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OnPurchaseRequestDtoFromJson(json);
}
