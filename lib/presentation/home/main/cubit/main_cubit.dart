import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/ads.dart';
import '../../../../model/dday.dart';
import '../../../../repository/ads/ads_repository.dart';
import '../../../../repository/dday/dday_repository.dart';
import '../../../../util/analytics_manager.dart';
import '../../../../util/cache_manager.dart';
import '../../../../util/const.dart';
import '../../../../util/dday_util.dart';
import '../../../app/cubit/app_cubit.dart';
import '../d_days_card.dart';

part 'main_cubit.freezed.dart';
part 'main_state.dart';

@lazySingleton
class MainCubit extends Cubit<MainState> {
  MainCubit(
    this._adsRepository,
    this._dDayRepository,
    this._cacheManager,
    this._sharedPreferences,
    this._appCubit,
  ) : super(const MainState());

  final AdsRepository _adsRepository;
  final DDayRepository _dDayRepository;
  final CacheManager _cacheManager;
  final SharedPreferences _sharedPreferences;
  final AppCubit _appCubit;

  void initialize() {
    updateAds();
    _updateDDays();
  }

  Future<void> updateAds() async {
    List<Ads>? cachedAds = _cacheManager.getAds();
    emit(state.copyWith(ads: _getAdsToShow(cachedAds ?? [])));

    final getAdsResult = await _adsRepository.getAllAds();
    if (getAdsResult.isError()) return;

    List<Ads>? ads = getAdsResult.tryGetSuccess();
    await _cacheManager.setAds(ads);
    await _preselectAdsVariants(ads ?? []);
    emit(state.copyWith(ads: _getAdsToShow(ads ?? []), adsShownLoggedMap: {}));
  }

  Future<void> _updateDDays() async {
    List<DDay>? cachedDDays = _cacheManager.getDDays();
    emit(state.copyWith(dDayItems: getDDayItemsToShow(cachedDDays ?? [])));

    final getDDaysResult = await _dDayRepository.getAllDDays();
    if (getDDaysResult.isError()) return;

    List<DDay>? dDays = getDDaysResult.tryGetSuccess();
    await _cacheManager.setDDays(dDays);
    emit(state.copyWith(dDayItems: getDDayItemsToShow(dDays ?? [])));
  }

  List<Ads> _getAdsToShow(List<Ads> ads) {
    final isPurchasedUser = _appCubit.state.me?.isPurchasedUser ?? false;
    final isAdsRemoved = _appCubit.state.productBenefit.isAdsRemoved;
    return ads
        .whereNot(
          (ad) => (isPurchasedUser && ad.isHiddenToPurchasedUser) || (isAdsRemoved && ad.isAd),
        )
        .toList();
  }

  Future<void> _preselectAdsVariants(List<Ads> ads) async {
    final List<String> selectedAdsVariantIds =
        _sharedPreferences.getStringList(PreferenceKey.selectedAdsVariantIds) ?? [];

    for (final ad in ads) {
      if (ad.variants.isEmpty) continue;

      final isAlreadySelected = ad.variants.any(
        (variant) => selectedAdsVariantIds.contains(variant.id),
      );
      if (isAlreadySelected) continue;

      final randomIndex = Random().nextInt(ad.variants.length);
      final selectedAdsVariantId = ad.variants[randomIndex].id;
      selectedAdsVariantIds.add(selectedAdsVariantId);

      AnalyticsManager.logEvent(
        name: '[HomePage-main] Silgam ads variant selected',
        properties: {'title': ad.title, 'variantId': selectedAdsVariantId},
      );
    }

    await _sharedPreferences.setStringList(
      PreferenceKey.selectedAdsVariantIds,
      selectedAdsVariantIds,
    );
  }

  List<DDayItem> getDDayItemsToShow(List<DDay> dDays) {
    return DDayUtil(dDays).getItemsToShow(DateTime.now());
  }

  void onAdsShown(int index, AdsVariant? variant) {
    if (state.adsShownLoggedMap[index] == true) return;
    emit(state.copyWith(adsShownLoggedMap: {...state.adsShownLoggedMap, index: true}));

    _logAdsEvent('shown', state.ads[index], index, variant);
  }

  void logAdsTap(Ads ads, int index, AdsVariant? variant) {
    _logAdsEvent('tapped', ads, index, variant);
  }

  void _logAdsEvent(String eventName, Ads ads, int index, AdsVariant? variant) {
    AnalyticsManager.logEvent(
      name: '[HomePage-main] Silgam ads $eventName',
      properties: {
        'title': ads.title,
        'actionIntents': ads.actions.map((e) => e.intent.toString()).join(', '),
        'actionData': ads.actions.map((e) => e.data).join(', '),
        'priority': ads.priority,
        'order': index + 1,
        'variantId': variant?.id ?? 'none',
      },
    );
  }

  AdsVariant? getSelectedAdsVariant(Ads ads) {
    if (ads.variants.isEmpty) return null;

    final List<String> selectedAdsVariantIds =
        _sharedPreferences.getStringList(PreferenceKey.selectedAdsVariantIds) ?? [];

    return ads.variants.firstWhereOrNull((variant) => selectedAdsVariantIds.contains(variant.id));
  }
}
