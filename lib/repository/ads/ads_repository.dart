import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../model/ads.dart';
import '../../util/api_failure.dart';
import 'ads_api.dart';

@lazySingleton
class AdsRepository {
  AdsRepository(this._adsApi);

  final AdsApi _adsApi;

  Future<Result<List<Ads>, ApiFailure>> getAllAds() async {
    try {
      final versionNumber = await _getVersionNumber();
      var ads = await _adsApi.getAllAds();
      ads = ads
          .where((ad) =>
              ad.minVersionNumber <= versionNumber &&
              ad.expiryDate.isAfter(DateTime.now()) &&
              ad.startDate.isBefore(DateTime.now()))
          .toList()
        ..shuffle()
        ..sort((a, b) => a.priority - b.priority);
      return Result.success(ads);
    } on DioException catch (e) {
      log(e.toString(), name: 'AdsRepository.getAllAds');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<int> _getVersionNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }
}
