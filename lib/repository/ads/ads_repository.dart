import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../model/ads.dart';
import '../../util/api_failure.dart';
import 'ads_api.dart';

@lazySingleton
class AdsRepository {
  AdsRepository(this._adsApi);

  final AdsApi _adsApi;

  Future<Result<List<Ads>, ApiFailure>> getAllAds() async {
    try {
      final ads = await _adsApi.getAllAds();
      ads.shuffle();
      ads.sort((a, b) => a.priority - b.priority);
      return Result.success(ads);
    } on DioError catch (e) {
      log(e.toString(), name: 'AdsRepository.getAllAds');
      return Result.error(e.error as ApiFailure);
    }
  }
}
