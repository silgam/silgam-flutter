import 'package:injectable/injectable.dart';

import '../../model/ads.dart';
import 'ads_api.dart';

@lazySingleton
class AdsRepository {
  AdsRepository(this._adsApi);

  final AdsApi _adsApi;
  List<Ads>? _ads;

  Future<List<Ads>> getAllAds() async {
    _ads ??= await _adsApi.getAllAds();
    _ads?.shuffle();
    _ads?.sort((a, b) => a.priority - b.priority);
    return _ads ?? [];
  }
}
