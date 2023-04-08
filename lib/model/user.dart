import 'package:freezed_annotation/freezed_annotation.dart';

import '../util/const.dart';
import 'product.dart';
import 'subject.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const User._();

  factory User({
    required final String id,
    required final Product activeProduct,
    String? displayName,
    String? email,
    String? photoUrl,
    @Default([]) List<ProviderData> providerDatas,
    @Default([]) List<String> fcmTokens,
    @Default([]) List<Receipt> receipts,
    bool? isMarketingInfoReceivingConsented,
    Map<Subject, String>? customSubjectNameMap,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool get isProductTrial =>
      activeProduct.id != ProductId.free && receipts.last.store == 'trial';

  bool get isPurchasedUser =>
      activeProduct.id != ProductId.free && !isProductTrial;
}

@freezed
class Receipt with _$Receipt {
  factory Receipt({
    required final String store,
    required final String productId,
    required final String token,
    required final DateTime createdAt,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);
}

@freezed
class ProviderData with _$ProviderData {
  factory ProviderData({
    required final String providerId,
  }) = _ProviderData;

  factory ProviderData.fromJson(Map<String, dynamic> json) =>
      _$ProviderDataFromJson(json);
}
