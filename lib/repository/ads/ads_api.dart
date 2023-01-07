import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../model/ads.dart';
import '../../util/const.dart';

part 'ads_api.g.dart';

@lazySingleton
@RestApi(baseUrl: urlSilgamHosting)
abstract class AdsApi {
  @factoryMethod
  factory AdsApi(Dio dio) = _AdsApi;

  @GET('/ads.json')
  Future<List<Ads>> getAllAds();
}
