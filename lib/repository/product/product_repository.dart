import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../model/product.dart';
import 'dto/on_purchase_request.dto.dart';
import 'dto/start-trial-request.dto.dart';
import 'product_api.dart';

@lazySingleton
class ProductRepository {
  ProductRepository(this._productApi);

  final ProductApi _productApi;

  Future<List<Product>> getActiveProducts() async {
    final products = await _productApi.getAllProducts();
    final today = DateTime.now();
    final versionNumber = await _getVersionNumber();
    return products
        .where((e) =>
            e.sellingStartDate.isBefore(today) &&
            e.sellingEndDate.isAfter(today) &&
            e.minVersionNumber <= versionNumber &&
            e.id != 'free')
        .toList();
  }

  Future<void> onPurchase({
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
    await _productApi.onPurchase('Bearer $authToken', request);
  }

  Future<void> startTrial({
    required String productId,
  }) async {
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final request = StartTrialRequestDto(
      productId: productId,
    );
    await _productApi.startTrial('Bearer $authToken', request);
  }

  Future<int> _getVersionNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }
}
