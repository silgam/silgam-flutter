import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      final filteredAds = await _getFilteredAndSortedAds(ads);

      return Result.success(filteredAds);
    } on DioException catch (e) {
      log(e.toString(), name: 'AdsRepository.getAllAds');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<List<Ads>> _getFilteredAndSortedAds(List<Ads> ads) async {
    final versionNumber = await _getVersionNumber();

    return ads
        .where(
          (ad) =>
              ad.minVersionNumber <= versionNumber &&
              (ad.maxVersionNumber == null || ad.maxVersionNumber! >= versionNumber) &&
              ad.expiryDate.isAfter(DateTime.now()) &&
              ad.startDate.isBefore(DateTime.now()),
        )
        .groupListsBy((ad) => ad.category)
        .entries
        .expand((entry) {
          final category = entry.key;
          final categoryAds = entry.value;
          final showCount = categoryAds.firstOrNull?.showCountInCategory;

          if (category == null || showCount == null) {
            return categoryAds;
          }

          return categoryAds.shuffled().take(showCount);
        })
        .shuffled()
        .sorted((a, b) => a.priority - b.priority);
  }

  Future<int> _getVersionNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }
}
