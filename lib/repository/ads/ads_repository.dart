import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/ads.dart';
import '../../util/api_failure.dart';
import 'ads_api.dart';

const _preferenceKeyAds = 'ads';

@lazySingleton
class AdsRepository {
  AdsRepository(this._adsApi, this._sharedPreferences);

  final AdsApi _adsApi;
  final SharedPreferences _sharedPreferences;

  Future<Result<List<Ads>, ApiFailure>> getAllAds() async {
    try {
      var ads = <Ads>[];
      final cachedAds = _sharedPreferences.getString(_preferenceKeyAds);
      if (cachedAds != null) {
        log('Set ads from cache: $cachedAds', name: 'AdsRepository');
        ads = (jsonDecode(cachedAds) as List)
            .map((e) => Ads.fromJson(e as Map<String, dynamic>))
            .toList();

        _adsApi.getAllAds().then((value) async {
          await _sharedPreferences.setString(
              _preferenceKeyAds, jsonEncode(value));
        });
      } else {
        ads = await _adsApi.getAllAds();
        await _sharedPreferences.setString(_preferenceKeyAds, jsonEncode(ads));
      }

      ads.shuffle();
      ads.sort((a, b) => a.priority - b.priority);
      return Result.success(ads);
    } on DioError catch (e) {
      log(e.toString(), name: 'AdsRepository.getAllAds');
      return Result.error(e.error as ApiFailure);
    }
  }
}
