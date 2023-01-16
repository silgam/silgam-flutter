import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  factory User({
    required final String id,
    required final Product activeProduct,
    String? displayName,
    String? email,
    String? photoUrl,
    @Default([]) List<ProviderData> providerDatas,
    @Default([]) List<String> fcmTokens,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class ProviderData with _$ProviderData {
  factory ProviderData({
    required final String providerId,
  }) = _ProviderData;

  factory ProviderData.fromJson(Map<String, dynamic> json) =>
      _$ProviderDataFromJson(json);
}
