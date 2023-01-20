import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:injectable/injectable.dart';

import '../../../model/product.dart';
import '../../../repository/product/product_repository.dart';
import '../../app/cubit/app_cubit.dart';

part 'iap_cubit.freezed.dart';
part 'iap_state.dart';

@lazySingleton
class IapCubit extends Cubit<IapState> {
  IapCubit(this._productRepository, this._appCubit)
      : super(const IapState.initial());

  final ProductRepository _productRepository;
  final AppCubit _appCubit;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription? _purchaseStream;

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));
    final isStoreAvailable = await _iap.isAvailable();
    if (!isStoreAvailable) {
      emit(const IapState.storeUnavailable(isLoading: false));
      return;
    }
    _purchaseStream = _iap.purchaseStream.listen(
      _onPurchaseStreamData,
      onError: (error) {
        log('[PurchaseCubit] onError: $error');
        emit(state.copyWith(isLoading: false));
      },
      onDone: () {
        log('[PurchaseCubit] onDone');
        emit(state.copyWith(isLoading: false));
      },
    );

    final productsResult = await _productRepository.getActiveProducts();
    final products = productsResult.tryGetSuccess();
    if (products == null) {
      emit(const IapState.storeUnavailable(isLoading: false));
      return;
    }

    final productDetailsResponse = await _iap.queryProductDetails(
      products.map((e) => e.id).toSet(),
    );
    final productDetails = productDetailsResponse.productDetails;

    if (productDetails.isEmpty) {
      emit(const IapState.storeUnavailable(isLoading: false));
      return;
    }

    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final skPaymentTransactionWrapper in transactions) {
        SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
      }
    }

    emit(IapState.loaded(
      products: products,
      productDetails: productDetails,
      isLoading: false,
    ));
  }

  Future<void> startFreeTrial(Product product) async {
    emit(state.copyWith(isLoading: true));
    final startTrialResult =
        await _productRepository.startTrial(productId: product.id);

    if (startTrialResult.isError()) {
      emit(state.copyWith(isLoading: false));
      EasyLoading.showError(startTrialResult.tryGetError()!.message);
      return;
    }

    await _appCubit.onUserChange();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> purchaseProduct(ProductDetails productDetails) async {
    emit(state.copyWith(isLoading: true));
    await _iap.buyConsumable(
      purchaseParam: PurchaseParam(
        productDetails: productDetails,
        applicationUserName: _appCubit.state.me!.id,
      ),
    );
  }

  Future<void> _onPurchaseStreamData(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          log('[PurchaseCubit] status.pending: ${purchaseDetails.verificationData.serverVerificationData}');
          if (purchaseDetails.pendingCompletePurchase) {
            await _onPurchased(purchaseDetails);
          }
          break;
        case PurchaseStatus.purchased:
          log('[PurchaseCubit] status.purchased: ${purchaseDetails.verificationData.serverVerificationData}');
          if (purchaseDetails.pendingCompletePurchase) {
            await _onPurchased(purchaseDetails);
          }
          break;
        case PurchaseStatus.error:
          log('[PurchaseCubit] status.error: ${purchaseDetails.error}');
          if (Platform.isIOS) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;
        case PurchaseStatus.canceled:
          log('[PurchaseCubit] status.canceled');
          if (Platform.isIOS) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;
        case PurchaseStatus.restored:
          log('[PurchaseCubit] status.restored: ${purchaseDetails.verificationData.serverVerificationData}');
          if (purchaseDetails.pendingCompletePurchase) {
            await _onPurchased(purchaseDetails);
          }
          break;
      }
    }
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onPurchased(PurchaseDetails purchaseDetails) async {
    final onPurchaseResult = await _productRepository.onPurchase(
      productId: purchaseDetails.productID,
      store: purchaseDetails.verificationData.source,
      verificationToken:
          purchaseDetails.verificationData.serverVerificationData,
    );

    if (onPurchaseResult.isError()) {
      emit(state.copyWith(isLoading: false));
      EasyLoading.showError(onPurchaseResult.tryGetError()!.message);
      return;
    }

    await _iap.completePurchase(purchaseDetails);
    await _appCubit.onUserChange();
  }

  @override
  Future<void> close() {
    _purchaseStream?.cancel();
    return super.close();
  }
}
