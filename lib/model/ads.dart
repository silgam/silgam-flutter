import 'package:freezed_annotation/freezed_annotation.dart';

part 'ads.freezed.dart';
part 'ads.g.dart';

@freezed
class Ads with _$Ads {
  const Ads._();

  const factory Ads({
    required String title,
    required String imagePath,
    @Default([]) List<AdsImage> images,
    required int priority,
    required List<AdsAction> actions,
    required DateTime startDate,
    required DateTime expiryDate,
    required int minVersionNumber,
    int? maxVersionNumber,
  }) = _Ads;

  factory Ads.fromJson(Map<String, dynamic> json) => _$AdsFromJson(json);

  bool get isHiddenToPurchasedUser =>
      actions.any((action) => action.intent == AdsIntent.openPurchasePage);

  bool get isAd => actions.any((action) => action.intent == AdsIntent.openAdUrl);
}

@freezed
class AdsImage with _$AdsImage {
  const factory AdsImage({required String id, required String url}) = _AdsImage;

  factory AdsImage.fromJson(Map<String, dynamic> json) => _$AdsImageFromJson(json);
}

@freezed
class AdsAction with _$AdsAction {
  const factory AdsAction({
    @JsonKey(unknownEnumValue: AdsIntent.unknown) required AdsIntent intent,
    required String data,
  }) = _AdsAction;

  factory AdsAction.fromJson(Map<String, dynamic> json) => _$AdsActionFromJson(json);
}

enum AdsIntent {
  openUrl,
  openAdUrl,
  openPurchasePage,
  openOfflineGuidePage,
  openCustomExamGuidePage,
  openPage,
  unknown,
}
