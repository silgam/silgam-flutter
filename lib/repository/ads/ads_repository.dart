import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../model/ads.dart';
import '../../util/api_failure.dart';
import 'ads_api.dart';

@lazySingleton
class AdsRepository {
  const AdsRepository(this._adsApi);

  final AdsApi _adsApi;

  Future<Result<List<Ads>, ApiFailure>> getAllAds() async {
    try {
      var ads = await _adsApi.getAllAds();
      return Result.success(ads);
    } on DioException catch (e) {
      log(e.toString(), name: 'AdsRepository.getAllAds');
      return Result.error(e.error as ApiFailure);
    }
  }
}
