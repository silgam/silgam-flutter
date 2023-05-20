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

    final cachedAds = _sharedPreferences.getString(PreferenceKey.cacheAds);
    if (cachedAds != null) {
      log('Set ads from cache: $cachedAds', name: 'MainCubit');
      final adsJson = jsonDecode(cachedAds) as List<dynamic>;
      final ads = adsJson.map((e) => Ads.fromJson(e)).toList();
      emit(state.copyWith(ads: ads));
    }

    final cachedDDays = _sharedPreferences.getString(PreferenceKey.cacheDDays);
    if (cachedDDays != null) {
      log('Set ddays from cache: $cachedDDays', name: 'MainCubit');
      final dDaysJson = jsonDecode(cachedDDays) as List<dynamic>;
      final dDays = dDaysJson.map((e) => DDay.fromJson(e)).toList();
      final dDayItems = DDayUtil(dDays).getItemsToShow(DateTime.now());
      emit(state.copyWith(dDayItems: dDayItems));
    }
  }

  Future<void> _updateAds() async {
    final getAdsResult = await _adsRepository.getAllAds();
    final ads = getAdsResult.tryGetSuccess()?.where((element) {
      if (element.intent?.contains(BannerIntent.openPurchasePage) == true &&
          _appCubit.state.me?.isPurchasedUser == true) {
        return false;
      }
      return true;
    }).toList();

    if (ads == null) {
      await _sharedPreferences.remove(PreferenceKey.cacheAds);
    } else {
      await _sharedPreferences.setString(
        PreferenceKey.cacheAds,
        jsonEncode(ads),
      );
    }

    emit(state.copyWith(ads: ads ?? []));
  }

  Future<void> _updateDDays() async {
    final dDaysResult = await _dDayRepository.getAllDDays();
    final dDays = dDaysResult.tryGetSuccess();

    if (dDays == null) {
      await _sharedPreferences.remove(PreferenceKey.cacheDDays);
    } else {
      await _sharedPreferences.setString(
        PreferenceKey.cacheDDays,
        jsonEncode(dDays),
      );
    }

    final dDayItems = DDayUtil(dDays ?? []).getItemsToShow(DateTime.now());

    emit(state.copyWith(dDayItems: dDayItems));
  }
}
