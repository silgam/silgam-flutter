import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';

import '../../../model/product.dart';
import '../../../repository/product/product_repository.dart';

part 'purchase_cubit.freezed.dart';
part 'purchase_state.dart';

@injectable
class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit(this._productRepository)
      : super(const PurchaseState.initial()) {
    _initialize();
  }

  final ProductRepository _productRepository;
  final InAppPurchase _iap = InAppPurchase.instance;

  void _initialize() async {
    final isStoreAvailable = await _iap.isAvailable();
    if (!isStoreAvailable) {
      emit(const PurchaseState.storeUnavailable());
      return;
    }
    _iap.purchaseStream.listen(
      _onPurchaseStreamData,
      onError: (error) => log('[PurchaseCubit] onError: $error'),
      onDone: () => log('[PurchaseCubit] onDone'),
    );

    final products = await _productRepository.getActiveProducts();
    final productDetailsResponse = await _iap.queryProductDetails(
      products.map((e) => e.id).toSet(),
    );
    final productDetails = productDetailsResponse.productDetails;

    if (productDetails.isEmpty) {
      emit(const PurchaseState.storeUnavailable());
      return;
    }

    emit(PurchaseState.loaded(
      product: products[0],
      productDetails: productDetails[0],
    ));
  }

  void _onPurchaseStreamData(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          log('[PurchaseCubit] status.pending: ${purchaseDetails.verificationData.serverVerificationData}');
          break;
        case PurchaseStatus.purchased:
          log('[PurchaseCubit] status.purchased: ${purchaseDetails.verificationData.serverVerificationData}');
          _onPurchased(purchaseDetails);
          break;
        case PurchaseStatus.error:
          log('[PurchaseCubit] status.error: ${purchaseDetails.error}');
          break;
        case PurchaseStatus.canceled:
          log('[PurchaseCubit] status.canceled');
          break;
        case PurchaseStatus.restored:
          log('[PurchaseCubit] status.restored: ${purchaseDetails.verificationData.serverVerificationData}');
          break;
      }
    }
  }

  Future<void> _onPurchased(PurchaseDetails purchaseDetails) async {
    await _productRepository.verifyPurchase(
      productId: purchaseDetails.productID,
      store: purchaseDetails.verificationData.source,
      verificationToken:
          purchaseDetails.verificationData.serverVerificationData,
    );
    await _iap.completePurchase(purchaseDetails);
  }
}
