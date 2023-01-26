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
    required final int originalPrice,
    required final int trialPeriod,
    required final int minVersionNumber,
    required final String pageUrl,
    required final String pageBackgroundColor,
    required final bool isPageBackgroundDark,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
