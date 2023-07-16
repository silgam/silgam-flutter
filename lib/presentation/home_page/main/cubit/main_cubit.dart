import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/ads.dart';
import '../../../../model/dday.dart';
import '../../../../repository/ads/ads_repository.dart';
import '../../../../repository/dday/dday_repository.dart';
import '../../../../util/const.dart';
import '../../../../util/dday_util.dart';
import '../../../app/cubit/app_cubit.dart';
import '../main_view.dart';

part 'main_cubit.freezed.dart';
part 'main_state.dart';

@lazySingleton
class MainCubit extends Cubit<MainState> {
  MainCubit(
    this._adsRepository,
    this._dDayRepository,
    this._sharedPreferences,
    this._appCubit,
  ) : super(const MainState());

  final AdsRepository _adsRepository;
  final DDayRepository _dDayRepository;
  final SharedPreferences _sharedPreferences;

  final AppCubit _appCubit;

  void initialize() {
    _updateAds();
    _updateDDays();

    try {
      final ads = _fetchAdsFromCache();
      if (ads != null) _updateAds(cachedAds: ads);
    } catch (e) {
      log(
        'Failed to update ads from cache: $e',
        name: runtimeType.toString(),
        error: e,
        stackTrace: StackTrace.current,
      );
    }
    try {
      final dDays = _fetchDDaysFromCache();
      if (dDays != null) _updateDDays(cachedDDays: dDays);
    } catch (e) {
      log(
        'Failed to update dDays from cache: $e',
        name: runtimeType.toString(),
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  Future<void> _updateAds({
    List<Ads>? cachedAds,
  }) async {
    List<Ads> ads = [];

    if (cachedAds != null) {
      ads = cachedAds;
    } else {
      final getAdsResult = await _adsRepository.getAllAds();
      final adsResult = getAdsResult.tryGetSuccess();
      if (adsResult == null) {
        await _sharedPreferences.remove(PreferenceKey.cacheAds);
      } else {
        await _sharedPreferences.setString(
          PreferenceKey.cacheAds,
          jsonEncode(adsResult),
        );
      }
      ads = adsResult ?? [];
    }

    emit(state.copyWith(
      ads: ads
          .where((element) =>
              element.intent?.contains(BannerIntent.openPurchasePage) != true ||
              _appCubit.state.me?.isPurchasedUser != true)
          .toList(),
    ));
  }

  Future<void> _updateDDays({
    List<DDay>? cachedDDays,
  }) async {
    List<DDay> dDays = [];

    if (cachedDDays != null) {
      dDays = cachedDDays;
    } else {
      final getDDaysResult = await _dDayRepository.getAllDDays();
      final dDaysResult = getDDaysResult.tryGetSuccess();
      if (dDaysResult == null) {
        await _sharedPreferences.remove(PreferenceKey.cacheDDays);
      } else {
        await _sharedPreferences.setString(
          PreferenceKey.cacheDDays,
          jsonEncode(dDaysResult),
        );
      }
      dDays = dDaysResult ?? [];
    }

    final dDayItems = DDayUtil(dDays).getItemsToShow(DateTime.now());

    emit(state.copyWith(dDayItems: dDayItems));
  }

  List<Ads>? _fetchAdsFromCache() {
    final cachedAds = _sharedPreferences.getString(PreferenceKey.cacheAds);
    if (cachedAds == null) return null;

    log('Set ads from cache: $cachedAds', name: runtimeType.toString());
    final adsJson = jsonDecode(cachedAds) as List<dynamic>;
    return adsJson.map((e) => Ads.fromJson(e)).toList();
  }

  List<DDay>? _fetchDDaysFromCache() {
    final cachedDDays = _sharedPreferences.getString(PreferenceKey.cacheDDays);
    if (cachedDDays == null) return null;

    log('Set ddays from cache: $cachedDDays', name: runtimeType.toString());
    final dDaysJson = jsonDecode(cachedDDays) as List<dynamic>;
    return dDaysJson.map((e) => DDay.fromJson(e)).toList();
  }
}
