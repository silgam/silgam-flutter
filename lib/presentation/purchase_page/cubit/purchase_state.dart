part of 'purchase_cubit.dart';

@freezed
class PurchaseState with _$PurchaseState {
  const factory PurchaseState.initial() = _Initial;
  const factory PurchaseState.loaded({
    required final Product product,
    required final ProductDetails productDetails,
  }) = _Loaded;
  const factory PurchaseState.storeUnavailable() = _StoreUnavailable;
}
