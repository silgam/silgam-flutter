import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../model/product.dart';
import '../../util/api_failure.dart';
import 'dto/on_purchase_request.dto.dart';
import 'dto/start-trial-request.dto.dart';
import 'product_api.dart';

@lazySingleton
class ProductRepository {
  ProductRepository(this._productApi);

  final ProductApi _productApi;

  Future<Result<List<Product>, ApiFailure>> getActiveProducts() async {
    try {
      final products = await _productApi.getAllProducts();
      final today = DateTime.now();
      final versionNumber = await _getVersionNumber();
      final activeProducts = products
          .where((e) =>
              e.sellingStartDate.isBefore(today) &&
              e.sellingEndDate.isAfter(today) &&
              e.minVersionNumber <= versionNumber &&
              e.id != 'free')
          .toList();
      return Result.success(activeProducts);
    } on DioError catch (e) {
      log(e.toString(), name: 'ProductRepository.getActiveProducts');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<Result<Unit, ApiFailure>> onPurchase({
    required String productId,
    required String store,
    required String verificationToken,
  }) async {
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final request = OnPurchaseRequestDto(
      productId: productId,
      store: store,
      verificationToken: verificationToken,
    );
    try {
      await _productApi.onPurchase('Bearer $authToken', request);
      return Result.success(unit);
    } on DioError catch (e) {
      log(e.toString(), name: 'ProductRepository.onPurchase');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<Result<Unit, ApiFailure>> startTrial({
    required String productId,
  }) async {
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final request = StartTrialRequestDto(
      productId: productId,
    );
    try {
      await _productApi.startTrial('Bearer $authToken', request);
      return Result.success(unit);
    } on DioError catch (e) {
      log(e.toString(), name: 'ProductRepository.startTrial');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<int> _getVersionNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }
}
