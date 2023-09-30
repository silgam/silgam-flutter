import 'dart:convert';
import 'dart:developer';

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
    try {
      final meString = _sharedPreferences.getString(PreferenceKey.cacheMe);
      if (meString == null) return null;
      return User.fromJson(jsonDecode(meString));
    } catch (e) {
      _logError('getMe', e);
      return null;
    }
  }

  Future<void> setMe(User? me) async {
    if (me == null) {
      await _sharedPreferences.remove(PreferenceKey.cacheMe);
    } else {
      await _sharedPreferences.setString(PreferenceKey.cacheMe, jsonEncode(me));
    }
  }

  List<Ads>? getAds() {
    try {
      final adsString = _sharedPreferences.getString(PreferenceKey.cacheAds);
      if (adsString == null) return null;
      final adsJson = jsonDecode(adsString) as List<dynamic>;
      return adsJson.map((e) => Ads.fromJson(e)).toList();
    } catch (e) {
      _logError('getAds', e);
      return null;
    }
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
    try {
      final cachedDDays =
          _sharedPreferences.getString(PreferenceKey.cacheDDays);
      if (cachedDDays == null) return null;
      final dDaysJson = jsonDecode(cachedDDays) as List<dynamic>;
      return dDaysJson.map((e) => DDay.fromJson(e)).toList();
    } catch (e) {
      _logError('getDDays', e);
      return null;
    }
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
    try {
      final cachedProducts =
          _sharedPreferences.getString(PreferenceKey.cacheProducts);
      if (cachedProducts == null) return null;
      final productsJson = jsonDecode(cachedProducts) as List<dynamic>;
      return productsJson.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      _logError('getProducts', e);
      return null;
    }
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

  void _logError(String name, Object e) {
    log(
      '$name error: $e',
      name: runtimeType.toString(),
      error: e,
      stackTrace: StackTrace.current,
    );
  }
}
