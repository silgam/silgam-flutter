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

  static const _cacheDuration = Duration(days: 7);
  final SharedPreferences _sharedPreferences;

  User? getMe() {
    try {
      final meString = _sharedPreferences.getString(PreferenceKey.cacheMe);
      final isExpired = _isCacheExpired(PreferenceKey.cacheMe);
      if (meString == null || isExpired) return null;

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
    await _setLastUpdated(PreferenceKey.cacheMe);
  }

  List<Ads>? getAds() {
    try {
      final adsString = _sharedPreferences.getString(PreferenceKey.cacheAds);
      final isExpired = _isCacheExpired(PreferenceKey.cacheAds);
      if (adsString == null || isExpired) return null;

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
    await _setLastUpdated(PreferenceKey.cacheAds);
  }

  List<DDay>? getDDays() {
    try {
      final cachedDDays =
          _sharedPreferences.getString(PreferenceKey.cacheDDays);
      final isExpired = _isCacheExpired(PreferenceKey.cacheDDays);
      if (cachedDDays == null || isExpired) return null;

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
    await _setLastUpdated(PreferenceKey.cacheDDays);
  }

  List<Product>? getProducts() {
    try {
      final cachedProducts =
          _sharedPreferences.getString(PreferenceKey.cacheProducts);
      final isExpired = _isCacheExpired(PreferenceKey.cacheProducts);
      if (cachedProducts == null || isExpired) return null;

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
    await _setLastUpdated(PreferenceKey.cacheProducts);
  }

  bool _isCacheExpired(String cacheKey) {
    final lastUpdatedString =
        _sharedPreferences.getString('${cacheKey}LastUpdated');
    if (lastUpdatedString == null) return true;
    final lastUpdated = DateTime.parse(lastUpdatedString);
    return lastUpdated.add(_cacheDuration).isBefore(DateTime.now().toUtc());
  }

  Future<bool> _setLastUpdated(String cacheKey) {
    return _sharedPreferences.setString(
      '${cacheKey}LastUpdated',
      DateTime.now().toUtc().toIso8601String(),
    );
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
