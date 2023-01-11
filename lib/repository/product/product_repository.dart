import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../model/product.dart';
import 'dto/verify-purchase.dto.dart';
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

  Future<void> verifyPurchase({
    required String productId,
    required String store,
    required String verificationToken,
  }) async {
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final request = VerifyPurchaseRequestDto(
      productId: productId,
      store: store,
      verificationToken: verificationToken,
    );
    await _productApi.verifyPurchase('Bearer $authToken', request);
  }

  Future<int> _getVersionNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }
}
