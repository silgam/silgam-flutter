part of 'purchase_cubit.dart';

@freezed
class PurchaseState with _$PurchaseState {
  const factory PurchaseState({
    @Default(true) bool isWebviewLoading,
  }) = _PurchaseState;
}
