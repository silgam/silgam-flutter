import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:injectable/injectable.dart';

import '../../../model/product.dart';
import '../../../repository/product/product_repository.dart';
import '../../app/cubit/app_cubit.dart';

part 'purchase_cubit.freezed.dart';
part 'purchase_state.dart';

@lazySingleton
class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit(this._productRepository, this._appCubit)
      : super(const PurchaseState.initial()) {
    _initialize();
  }

  final ProductRepository _productRepository;
  final AppCubit _appCubit;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription? _purchaseStream;

  Future<void> startFreeTrial(Product product) async {
    await _productRepository.startTrial(productId: product.id);
    _appCubit.updateMe();
  }

  Future<void> purchaseProduct(ProductDetails productDetails) async {
    await _iap.buyConsumable(
      purchaseParam: PurchaseParam(
        productDetails: productDetails,
        applicationUserName: _appCubit.state.me!.id,
      ),
    );
  }

  void _initialize() async {
    final isStoreAvailable = await _iap.isAvailable();
    if (!isStoreAvailable) {
      emit(const PurchaseState.storeUnavailable());
      return;
    }
    _purchaseStream = _iap.purchaseStream.listen(
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

    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final skPaymentTransactionWrapper in transactions) {
        SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
      }
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
          if (purchaseDetails.pendingCompletePurchase) {
            _onPurchased(purchaseDetails);
          }
          log('[PurchaseCubit] status.pending: ${purchaseDetails.verificationData.serverVerificationData}');
          break;
        case PurchaseStatus.purchased:
          log('[PurchaseCubit] status.purchased: ${purchaseDetails.verificationData.serverVerificationData}');
          if (purchaseDetails.pendingCompletePurchase) {
            _onPurchased(purchaseDetails);
          }
          break;
        case PurchaseStatus.error:
          if (Platform.isIOS) {
            _iap.completePurchase(purchaseDetails);
          }
          log('[PurchaseCubit] status.error: ${purchaseDetails.error}');
          break;
        case PurchaseStatus.canceled:
          if (Platform.isIOS) {
            _iap.completePurchase(purchaseDetails);
          }
          log('[PurchaseCubit] status.canceled');
          break;
        case PurchaseStatus.restored:
          if (purchaseDetails.pendingCompletePurchase) {
            _onPurchased(purchaseDetails);
          }
          log('[PurchaseCubit] status.restored: ${purchaseDetails.verificationData.serverVerificationData}');
          break;
      }
    }
  }

  Future<void> _onPurchased(PurchaseDetails purchaseDetails) async {
    await _productRepository.onPurchase(
      productId: purchaseDetails.productID,
      store: purchaseDetails.verificationData.source,
      verificationToken:
          purchaseDetails.verificationData.serverVerificationData,
    );
    await _iap.completePurchase(purchaseDetails);
    await _appCubit.updateMe();
  }

  @override
  Future<void> close() {
    _purchaseStream?.cancel();
    return super.close();
  }
}
