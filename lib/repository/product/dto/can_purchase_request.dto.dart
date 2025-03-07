import 'package:freezed_annotation/freezed_annotation.dart';

part 'can_purchase_request.dto.freezed.dart';
part 'can_purchase_request.dto.g.dart';

@freezed
class CanPurchaseRequestDto with _$CanPurchaseRequestDto {
  const factory CanPurchaseRequestDto({required String productId, required String store}) =
      _CanPurchaseRequestDto;

  factory CanPurchaseRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CanPurchaseRequestDtoFromJson(json);
}
