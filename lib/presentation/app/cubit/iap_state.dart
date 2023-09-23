part of 'iap_cubit.dart';

@freezed
class IapState with _$IapState {
  const IapState._();

  const factory IapState({
    @Default(null) final Product? sellingProduct,
    @Default([]) final List<Product> products,
    @Default([]) final List<ProductDetails> productDetails,
    @Default(false) final bool isStoreAvailable,
    @Default(false) final bool isLoading,
  }) = _IapState;

  Product? get freeProduct =>
      products.firstWhereOrNull((product) => product.id == ProductId.free);
}
