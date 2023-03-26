import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  factory Product({
    required final String id,
    required final String name,
    required final DateTime expiryDate,
    required final DateTime sellingStartDate,
    required final DateTime sellingEndDate,
    required final int trialPeriod,
    required final int minVersionNumber,
    required final String stampImageUrl,
    required final String trialStampImageUrl,
    required final String pageUrl,
    required final String pageBackgroundColor,
    required final bool isPageBackgroundDark,
    required final ProductBenefit benefit,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
class ProductBenefit with _$ProductBenefit {
  const factory ProductBenefit({
    required final bool isAdsRemoved,
    required final bool isStatisticAvailable,
    required final int examRecordLimit,
    required final List<int> availableNoiseIds,
    required final bool isCustomSubjectNameAvailable,
  }) = _ProductBenefit;

  factory ProductBenefit.fromJson(Map<String, dynamic> json) =>
      _$ProductBenefitFromJson(json);

  static const ProductBenefit initial = ProductBenefit(
    isAdsRemoved: false,
    isStatisticAvailable: false,
    examRecordLimit: 30,
    availableNoiseIds: [0, 2, 3, 10, 12],
    isCustomSubjectNameAvailable: false,
  );
}
