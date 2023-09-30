import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ads.dart';
import '../model/dday.dart';
import '../model/product.dart';
import '../model/user.dart';
import 'const.dart';

@lazySingleton
class CacheManager {
  const CacheManager(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  User? getMe() {
    final meString = _sharedPreferences.getString(PreferenceKey.cacheMe);
    if (meString == null) return null;
    return User.fromJson(jsonDecode(meString));
  }

  Future<void> setMe(User? me) async {
    if (me == null) {
      await _sharedPreferences.remove(PreferenceKey.cacheMe);
    } else {
      await _sharedPreferences.setString(PreferenceKey.cacheMe, jsonEncode(me));
    }
  }

  List<Ads>? getAds() {
    final adsString = _sharedPreferences.getString(PreferenceKey.cacheAds);
    if (adsString == null) return null;
    final adsJson = jsonDecode(adsString) as List<dynamic>;
    return adsJson.map((e) => Ads.fromJson(e)).toList();
  }

  Future<void> setAds(List<Ads>? ads) async {
    if (ads == null) {
      await _sharedPreferences.remove(PreferenceKey.cacheAds);
    } else {
      await _sharedPreferences.setString(
        PreferenceKey.cacheAds,
        jsonEncode(ads),
      );
    }
  }

  List<DDay>? getDDays() {
    final cachedDDays = _sharedPreferences.getString(PreferenceKey.cacheDDays);
    if (cachedDDays == null) return null;
    final dDaysJson = jsonDecode(cachedDDays) as List<dynamic>;
    return dDaysJson.map((e) => DDay.fromJson(e)).toList();
  }

  Future<void> setDDays(List<DDay>? dDays) async {
    if (dDays == null) {
      await _sharedPreferences.remove(PreferenceKey.cacheDDays);
    } else {
      await _sharedPreferences.setString(
        PreferenceKey.cacheDDays,
        jsonEncode(dDays),
      );
    }
  }

  List<Product>? getProducts() {
    final cachedProducts =
        _sharedPreferences.getString(PreferenceKey.cacheProducts);
    if (cachedProducts == null) return null;
    final productsJson = jsonDecode(cachedProducts) as List<dynamic>;
    return productsJson.map((e) => Product.fromJson(e)).toList();
  }

  Future<void> setProducts(List<Product>? products) async {
    if (products == null) {
      await _sharedPreferences.remove(PreferenceKey.cacheProducts);
    } else {
      await _sharedPreferences.setString(
        PreferenceKey.cacheProducts,
        jsonEncode(products),
      );
    }
  }
}
