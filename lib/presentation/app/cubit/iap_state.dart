part of 'iap_cubit.dart';

@freezed
class IapState with _$IapState {
  const factory IapState({
    @Default([]) final List<Product> products,
    @Default([]) final List<ProductDetails> productDetails,
    @Default(false) final bool isStoreAvailable,
    @Default(false) final bool isLoading,
  }) = _IapState;
}
