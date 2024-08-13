import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../model/product.dart';
import '../../util/api_failure.dart';
import 'dto/can_purchase_request.dto.dart';
import 'dto/on_purchase_request.dto.dart';
import 'dto/start_trial_request.dto.dart';
import 'product_api.dart';

@lazySingleton
class ProductRepository {
  const ProductRepository(this._productApi);

  final ProductApi _productApi;

  Future<Result<List<Product>, ApiFailure>> getAllProducts() async {
    try {
      final products = await _productApi.getAllProducts();
      final productsLocal = <Product>[];
      for (final product in products) {
        productsLocal.add(product.copyWith(
          expiryDate: product.expiryDate.toLocal(),
          sellingStartDate: product.sellingStartDate.toLocal(),
          sellingEndDate: product.sellingEndDate.toLocal(),
        ));
      }
      return Result.success(productsLocal);
    } on DioException catch (e) {
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
      return const Result.success(unit);
    } on DioException catch (e) {
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
      return const Result.success(unit);
    } on DioException catch (e) {
      log(e.toString(), name: 'ProductRepository.startTrial');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<Result<Unit, ApiFailure>> canPurchase({
    required String productId,
    required String store,
  }) async {
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final request = CanPurchaseRequestDto(
      productId: productId,
      store: store,
    );
    try {
      await _productApi.canPurchase('Bearer $authToken', request);
      return const Result.success(unit);
    } on DioException catch (e) {
      log(e.toString(), name: 'ProductRepository.canPurchase');
      return Result.error(e.error as ApiFailure);
    }
  }
}
