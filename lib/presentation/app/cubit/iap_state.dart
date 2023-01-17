part of 'iap_cubit.dart';

@freezed
class IapState with _$IapState {
  const factory IapState.initial({
    @Default(false) final bool isLoading,
  }) = _Initial;

  const factory IapState.loaded({
    required final List<Product> products,
    required final List<ProductDetails> productDetails,
    @Default(false) final bool isLoading,
  }) = _Loaded;

  const factory IapState.storeUnavailable({
    @Default(false) final bool isLoading,
  }) = _StoreUnavailable;
}
