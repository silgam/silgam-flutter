import 'package:freezed_annotation/freezed_annotation.dart';

part 'ads.freezed.dart';
part 'ads.g.dart';

@freezed
class Ads with _$Ads {
  const factory Ads({
    required String title,
    required String imagePath,
    required int priority,
    required DateTime startDate,
    required DateTime expiryDate,
    required int minVersionNumber,
    String? intent,
    String? url,
  }) = _Ads;

  factory Ads.fromJson(Map<String, dynamic> json) => _$AdsFromJson(json);
}
