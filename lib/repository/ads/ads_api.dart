import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../model/ads.dart';

part 'ads_api.g.dart';

@lazySingleton
@RestApi()
abstract class AdsApi {
  @factoryMethod
  factory AdsApi(Dio dio) = _AdsApi;

  @GET('/ads')
  Future<List<Ads>> getAllAds();
}
