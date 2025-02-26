import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../model/product.dart';
import '../../../repository/product/product_repository.dart';
import '../../../util/analytics_manager.dart';
import '../../../util/cache_manager.dart';
import '../../../util/const.dart';
import '../../app/cubit/app_cubit.dart';

part 'iap_cubit.freezed.dart';
part 'iap_state.dart';

@lazySingleton
class IapCubit extends Cubit<IapState> {
  IapCubit(this._productRepository, this._appCubit, this._cacheManager)
    : super(const IapState());

  final ProductRepository _productRepository;
  final CacheManager _cacheManager;
  final AppCubit _appCubit;
  late final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription? _purchaseStream;

  void initialize() {
    if (!kIsWeb) {
      _purchaseStream?.cancel();
      _purchaseStream = _iap.purchaseStream.listen(
        _onPurchaseStreamData,
        onError: _onPurchaseStreamError,
        onDone: _onPurchaseStreamDone,
      );
      _checkStoreAvailability();
    }

    _updateProducts();
    _appCubit.updateProductBenefit();
  }

  Future<void> startFreeTrialProcess(Product product) async {
    AnalyticsManager.logEvent(
      name: '[PurchasePage] Start free trial process start',
      properties: {'product_id': product.id, 'product_name': product.name},
    );

    final me = _appCubit.state.me;
    if (me == null) {
      EasyLoading.showError('먼저 로그인해주세요.', dismissOnTap: true);
      AnalyticsManager.logEvent(
        name: '[PurchasePage] Start free trial process failed',
        properties: {
          'reason': 'Not logged in',
          'product_id': product.id,
          'product_name': product.name,
        },
      );
      return;
    }

    emit(state.copyWith(isLoading: true));
    if (Platform.isIOS) {
      await _startFreeTrialIos(product);
    } else {
      await _startFreeTrial(product);
    }
  }

  Future<void> purchaseProduct(Product product) async {
    AnalyticsManager.logEvent(
      name: '[PurchasePage] Purchase process start',
      properties: {'product_id': product.id, 'product_name': product.name},
    );

    final me = _appCubit.state.me;
    if (me == null) {
      EasyLoading.showError('먼저 로그인해주세요.', dismissOnTap: true);
      AnalyticsManager.logEvent(
        name: '[PurchasePage] Purchase process failed',
        properties: {
          'reason': 'Not logged in',
          'product_id': product.id,
          'product_name': product.name,
        },
      );
      return;
    }

    if (!state.isStoreAvailable) {
      EasyLoading.showError(
        '이 기기에서는 구매가 불가능합니다. 스토어가 설치되어 있는지 확인해주세요.',
        dismissOnTap: true,
      );
      AnalyticsManager.logEvent(
        name: '[PurchasePage] Purchase process failed',
        properties: {
          'reason': 'Store not available',
          'product_id': product.id,
          'product_name': product.name,
        },
      );
      return;
    }

    final productDetails = state.productDetails.firstWhereOrNull(
      (productDetails) => productDetails.id == product.id,
    );
    if (productDetails == null) {
      EasyLoading.showError(
        '정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
        dismissOnTap: true,
      );
      AnalyticsManager.logEvent(
        name: '[PurchasePage] Purchase process failed',
        properties: {
          'reason': 'Product details not found',
          'product_id': product.id,
          'product_name': product.name,
        },
      );
      return;
    }

    emit(state.copyWith(isLoading: true));

    final canPurchaseResult = await _productRepository.canPurchase(
      productId: productDetails.id,
      store: Platform.isIOS ? 'app_store' : 'google_play',
    );
    if (canPurchaseResult.isError()) {
      emit(state.copyWith(isLoading: false));
      final message = canPurchaseResult.tryGetError()!.message;
      EasyLoading.showError(
        canPurchaseResult.tryGetError()!.message,
        dismissOnTap: true,
      );
      AnalyticsManager.logEvent(
        name: '[PurchasePage] Purchase process failed',
        properties: {
          'reason': 'canPurchaseRequest failed: $message',
          'product_id': product.id,
          'product_name': product.name,
        },
      );
      return;
    }

    await _iap.buyConsumable(
      purchaseParam: PurchaseParam(
        productDetails: productDetails,
        applicationUserName: _appCubit.state.me!.id,
      ),
    );
  }

  Future<void> _startFreeTrialIos(Product product) async {
    final trialProductDetailResponse = await _iap.queryProductDetails({
      '${product.id}_trial',
    });

    if (trialProductDetailResponse.error != null ||
        trialProductDetailResponse.productDetails.isEmpty) {
      emit(state.copyWith(isLoading: false));
      EasyLoading.showError(
        '정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
        dismissOnTap: true,
      );
      AnalyticsManager.logEvent(
        name: '[PurchasePage] Start free trial process failed',
        properties: {
          'reason':
              'productDetailsList is empty or queryProductDetails failed: ${trialProductDetailResponse.error!.message}',
          'product_id': product.id,
          'product_name': product.name,
        },
      );
      return;
    }

    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: trialProductDetailResponse.productDetails.first,
      ),
    );
  }

  Future<void> _startFreeTrial(Product product) async {
    final startTrialResult = await _productRepository.startTrial(
      productId: product.id,
    );

    if (startTrialResult.isError()) {
      emit(state.copyWith(isLoading: false));
      final message = startTrialResult.tryGetError()!.message;
      EasyLoading.showError(message, dismissOnTap: true);
      AnalyticsManager.logEvent(
        name: '[PurchasePage] Start free trial process failed',
        properties: {
          'reason': 'startTrialRequest failed: $message',
          'product_id': product.id,
          'product_name': product.name,
        },
      );
      return;
    }

    await _appCubit.onUserChange();

    AnalyticsManager.logEvent(
      name: '[PurchasePage] Start free trial process success',
      properties: {'product_id': product.id, 'product_name': product.name},
    );

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onPurchaseStreamData(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          log(
            '[PurchaseCubit] status.pending: ${purchaseDetails.verificationData.serverVerificationData}',
          );
          if (purchaseDetails.pendingCompletePurchase) {
            await _onPurchased(purchaseDetails);
          }
          break;
        case PurchaseStatus.purchased:
          log(
            '[PurchaseCubit] status.purchased: ${purchaseDetails.verificationData.serverVerificationData}',
          );
          if (purchaseDetails.pendingCompletePurchase) {
            await _onPurchased(purchaseDetails);
          }
          break;
        case PurchaseStatus.error:
          log('[PurchaseCubit] status.error: ${purchaseDetails.error}');
          AnalyticsManager.logEvent(
            name: '[PurchasePage] Purchase process failed',
            properties: {
              'reason': 'Purchase stream error: ${purchaseDetails.error}',
            },
          );
          if (Platform.isIOS) {
            await _iap.completePurchase(purchaseDetails);
          }
          emit(state.copyWith(isLoading: false));
          break;
        case PurchaseStatus.canceled:
          log('[PurchaseCubit] status.canceled');
          AnalyticsManager.logEvent(
            name: '[PurchasePage] Purchase process failed',
            properties: {'reason': 'Purchase canceled'},
          );
          if (Platform.isIOS) {
            await _iap.completePurchase(purchaseDetails);
          }
          emit(state.copyWith(isLoading: false));
          break;
        case PurchaseStatus.restored:
          log(
            '[PurchaseCubit] status.restored: ${purchaseDetails.verificationData.serverVerificationData}',
          );
          if (purchaseDetails.pendingCompletePurchase) {
            await _onPurchased(purchaseDetails);
          }
          break;
      }
    }
  }

  void _onPurchaseStreamError(Object error) {
    log('[PurchaseCubit] onError: $error');
    emit(state.copyWith(isLoading: false));
  }

  void _onPurchaseStreamDone() {
    log('[PurchaseCubit] onDone');
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onPurchased(PurchaseDetails purchaseDetails) async {
    AnalyticsManager.logEvent(
      name: '[PurchasePage] onPurchase start',
      properties: {
        'product_id': purchaseDetails.productID,
        'store': purchaseDetails.verificationData.source,
        'verification_token':
            purchaseDetails.verificationData.serverVerificationData,
      },
    );

    if (purchaseDetails.productID.contains('_trial')) {
      await _startFreeTrial(
        state.products.firstWhere(
          (product) => product.id == purchaseDetails.productID.split('_').first,
        ),
      );
      return;
    }

    final onPurchaseResult = await _productRepository.onPurchase(
      productId: purchaseDetails.productID,
      store: purchaseDetails.verificationData.source,
      verificationToken:
          purchaseDetails.verificationData.serverVerificationData,
    );

    if (onPurchaseResult.isError()) {
      emit(state.copyWith(isLoading: false));
      final message = onPurchaseResult.tryGetError()!.message;
      EasyLoading.showError(message, dismissOnTap: true);
      AnalyticsManager.logEvent(
        name: '[PurchasePage] onPurchase failed',
        properties: {
          'reason': 'onPurchaseRequest failed: $message',
          'product_id': purchaseDetails.productID,
          'store': purchaseDetails.verificationData.source,
          'verification_token':
              purchaseDetails.verificationData.serverVerificationData,
        },
      );
      return;
    }

    await _iap.completePurchase(purchaseDetails);
    await _appCubit.onUserChange();

    AnalyticsManager.logEvent(
      name: '[PurchasePage] onPurchase success',
      properties: {
        'product_id': purchaseDetails.productID,
        'store': purchaseDetails.verificationData.source,
        'verification_token':
            purchaseDetails.verificationData.serverVerificationData,
      },
    );

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _checkStoreAvailability() async {
    final isStoreAvailable = await _iap.isAvailable();
    emit(state.copyWith(isStoreAvailable: isStoreAvailable));

    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final skPaymentTransactionWrapper in transactions) {
        SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
      }
    }
  }

  Future<void> _updateProducts() async {
    List<Product>? cachedProducts = _cacheManager.getProducts();
    await _onProductsChange(cachedProducts ?? []);

    final getProductsResult = await _productRepository.getAllProducts();
    if (getProductsResult.isError()) return;

    List<Product>? products = getProductsResult.tryGetSuccess();
    _cacheManager.setProducts(products);
    await _onProductsChange(products ?? []);
  }

  Future<void> _onProductsChange(List<Product> products) async {
    final today = DateTime.now();
    final versionNumber = await _getVersionNumber();
    final sellingProduct = products.firstWhereOrNull(
      (e) =>
          e.sellingStartDate.isBefore(today) &&
          e.sellingEndDate.isAfter(today) &&
          e.minVersionNumber <= versionNumber &&
          e.id != ProductId.free,
    );
    emit(state.copyWith(sellingProduct: sellingProduct, products: products));
    _appCubit.updateProductBenefit();

    if (!kIsWeb && sellingProduct != null) {
      final productDetailsResponse = await _iap.queryProductDetails({
        sellingProduct.id,
      });
      final productDetails = productDetailsResponse.productDetails;
      emit(state.copyWith(productDetails: productDetails));
    }
  }

  Future<int> _getVersionNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }

  @override
  Future<void> close() {
    _purchaseStream?.cancel();
    return super.close();
  }
}
