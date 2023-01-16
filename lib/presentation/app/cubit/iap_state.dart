part of 'iap_cubit.dart';

@freezed
class IapState with _$IapState {
  const factory IapState.initial() = _Initial;
  const factory IapState.loaded({
    required final List<Product> products,
    required final List<ProductDetails> productDetails,
  }) = _Loaded;
  const factory IapState.storeUnavailable() = _StoreUnavailable;
}
