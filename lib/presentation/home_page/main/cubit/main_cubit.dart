import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/ads.dart';
import '../../../../repository/ads/ads_repository.dart';
import '../../../../repository/dday_repository.dart';

part 'main_cubit.freezed.dart';
part 'main_state.dart';

const _preferenceKeyAds = 'ads';

@lazySingleton
class MainCubit extends Cubit<MainState> {
  MainCubit(this._adsRepository, this._dDayRepository, this._sharedPreferences)
      : super(const MainState());

  final AdsRepository _adsRepository;
  final DDayRepository _dDayRepository;
  final SharedPreferences _sharedPreferences;

  void initialize() {
    final DateTime today = DateTime.now();
    emit(state.copyWith(
      dDayItems: _dDayRepository.getItemsToShow(today),
    ));

    final cachedAds = _sharedPreferences.getString(_preferenceKeyAds);
    if (cachedAds != null) {
      log('Set ads from cache: $cachedAds', name: 'MainCubit');
      final adsJson = jsonDecode(cachedAds) as List<dynamic>;
      emit(state.copyWith(
        ads: adsJson.map((e) => Ads.fromJson(e)).toList(),
      ));
    }
    _updateAds();
  }

  Future<void> _updateAds() async {
    final getAdsResult = await _adsRepository.getAllAds();
    final ads = getAdsResult.tryGetSuccess();

    if (ads == null) {
      await _sharedPreferences.remove(_preferenceKeyAds);
    } else {
      await _sharedPreferences.setString(
        _preferenceKeyAds,
        jsonEncode(ads),
      );
    }

    emit(state.copyWith(ads: ads ?? []));
  }
}
