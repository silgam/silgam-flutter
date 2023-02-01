import 'dart:async';
import 'dart:convert';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/product.dart';
import '../../../repository/product/product_repository.dart';
import '../../../util/const.dart';
import '../../app/cubit/app_cubit.dart';

part 'iap_cubit.freezed.dart';
part 'iap_state.dart';

@lazySingleton
class IapCubit extends Cubit<IapState> {
  IapCubit(
    this._productRepository,
    this._appCubit,
    this._sharedPreferences,
  ) : super(const IapState());

  final ProductRepository _productRepository;
  final SharedPreferences _sharedPreferences;
  final AppCubit _appCubit;
  late final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription? _purchaseStream;

  void initialize() {
    if (!kIsWeb) {
      _purchaseStream = _iap.purchaseStream.listen(
        _onPurchaseStreamData,
        onError: _onPurchaseStreamError,
        onDone: _onPurchaseStreamDone,
      );
      _checkStoreAvailability();
    }

    _fetchProducts();
    _appCubit.updateProductBenefit();
  }

  Future<void> startFreeTrial(Product product) async {
    final me = _appCubit.state.me;
    if (me == null) {
      EasyLoading.showError('먼저 로그인해주세요.');
      return;
    }

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

  Future<void> purchaseProduct(Product product) async {
    final me = _appCubit.state.me;
    if (me == null) {
      EasyLoading.showError('먼저 로그인해주세요.');
      return;
    }

    if (!state.isStoreAvailable) {
      EasyLoading.showError('이 기기에서는 구매가 불가능합니다. 스토어가 설치되어 있는지 확인해주세요.');
      return;
    }

    final productDetails = state.productDetails.firstWhereOrNull(
      (productDetails) => productDetails.id == product.id,
    );
    if (productDetails == null) {
      EasyLoading.showError('정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.');
      return;
    }

    emit(state.copyWith(isLoading: true));

    final canPurchaseResult = await _productRepository.canPurchase(
      productId: productDetails.id,
      store: Platform.isIOS ? 'app_store' : 'google_play',
    );
    if (canPurchaseResult.isError()) {
      emit(state.copyWith(isLoading: false));
      EasyLoading.showError(canPurchaseResult.tryGetError()!.message);
      return;
    }

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
          emit(state.copyWith(isLoading: false));
          break;
        case PurchaseStatus.canceled:
          log('[PurchaseCubit] status.canceled');
          if (Platform.isIOS) {
            await _iap.completePurchase(purchaseDetails);
          }
          emit(state.copyWith(isLoading: false));
          break;
        case PurchaseStatus.restored:
          log('[PurchaseCubit] status.restored: ${purchaseDetails.verificationData.serverVerificationData}');
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

  Future<void> _fetchProducts() async {
    _updateProducts();

    final cachedProducts =
        _sharedPreferences.getString(PreferenceKey.cacheProducts);
    if (cachedProducts != null) {
      log('Set products from cache: $cachedProducts', name: 'PurchaseCubit');
      final productsJson = jsonDecode(cachedProducts) as List<dynamic>;
      final products = productsJson.map((e) => Product.fromJson(e)).toList();
      emit(state.copyWith(activeProducts: products, products: products));
      _appCubit.updateProductBenefit();
    }
  }

  Future<void> _updateProducts() async {
    final productsResult = await _productRepository.getAllProducts();
    final products = productsResult.tryGetSuccess();
    if (products == null) {
      _sharedPreferences.remove(PreferenceKey.cacheProducts);
    } else {
      _sharedPreferences.setString(
        PreferenceKey.cacheProducts,
        jsonEncode(products),
      );
    }

    final today = DateTime.now();
    final versionNumber = await _getVersionNumber();
    final activeProducts = products
        ?.where((e) =>
            e.sellingStartDate.isBefore(today) &&
            e.sellingEndDate.isAfter(today) &&
            e.minVersionNumber <= versionNumber &&
            e.id != 'free')
        .toList();
    emit(state.copyWith(
      activeProducts: activeProducts ?? [],
      products: products ?? [],
    ));
    _appCubit.updateProductBenefit();

    if (!kIsWeb) {
      final productDetailsResponse = await _iap.queryProductDetails(
        activeProducts?.map((e) => e.id).toSet() ?? {},
      );
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
