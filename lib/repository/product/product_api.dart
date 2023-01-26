import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../model/product.dart';
import 'dto/can_purchase_request.dto.dart';
import 'dto/on_purchase_request.dto.dart';
import 'dto/start_trial_request.dto.dart';

part 'product_api.g.dart';

@lazySingleton
@RestApi()
abstract class ProductApi {
  @factoryMethod
  factory ProductApi(Dio dio) = _ProductApi;

  @GET('/products')
  Future<List<Product>> getAllProducts();

  @POST('/iap/on-purchase')
  Future<void> onPurchase(
    @Header('Authorization') String bearerToken,
    @Body() OnPurchaseRequestDto request,
  );

  @POST('/iap/start-trial')
  Future<void> startTrial(
    @Header('Authorization') String bearerToken,
    @Body() StartTrialRequestDto request,
  );

  @POST('/iap/can-purchase')
  Future<void> canPurchase(
    @Header('Authorization') String bearerToken,
    @Body() CanPurchaseRequestDto request,
  );
}
