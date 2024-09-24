import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../model/ads.dart';
import '../../../../model/dday.dart';
import '../../../../repository/ads/ads_repository.dart';
import '../../../../repository/dday/dday_repository.dart';
import '../../../../util/analytics_manager.dart';
import '../../../../util/cache_manager.dart';
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
    this._cacheManager,
    this._appCubit,
  ) : super(const MainState());

  final AdsRepository _adsRepository;
  final DDayRepository _dDayRepository;
  final CacheManager _cacheManager;

  final AppCubit _appCubit;

  void initialize() {
    updateAds();
    _updateDDays();
  }

  Future<void> updateAds() async {
    List<Ads>? cachedAds = _cacheManager.getAds();
    emit(state.copyWith(
      ads: _getAdsToShow(cachedAds ?? []),
    ));

    final getAdsResult = await _adsRepository.getAllAds();
    if (getAdsResult.isError()) return;

    List<Ads>? ads = getAdsResult.tryGetSuccess();
    await _cacheManager.setAds(ads);
    emit(state.copyWith(
      ads: _getAdsToShow(ads ?? []),
      adsShownLoggedMap: {},
    ));
  }

  Future<void> _updateDDays() async {
    List<DDay>? cachedDDays = _cacheManager.getDDays();
    emit(state.copyWith(
      dDayItems: getDDayItemsToShow(cachedDDays ?? []),
    ));

    final getDDaysResult = await _dDayRepository.getAllDDays();
    if (getDDaysResult.isError()) return;

    List<DDay>? dDays = getDDaysResult.tryGetSuccess();
    await _cacheManager.setDDays(dDays);
    emit(state.copyWith(
      dDayItems: getDDayItemsToShow(dDays ?? []),
    ));
  }

  List<Ads> _getAdsToShow(List<Ads> ads) {
    final isPurchasedUser = _appCubit.state.me?.isPurchasedUser ?? false;
    final isAdsRemoved = _appCubit.state.productBenefit.isAdsRemoved;
    return ads
        .whereNot((ad) =>
            (isPurchasedUser && ad.isHiddenToPurchasedUser) ||
            (isAdsRemoved && ad.isAd))
        .toList();
  }

  List<DDayItem> getDDayItemsToShow(List<DDay> dDays) {
    return DDayUtil(dDays).getItemsToShow(DateTime.now());
  }

  void onAdsShown(int index) {
    if (state.adsShownLoggedMap[index] == true) return;
    emit(state.copyWith(
      adsShownLoggedMap: {...state.adsShownLoggedMap, index: true},
    ));

    final Ads ads = state.ads[index];
    AnalyticsManager.logEvent(
      name: '[HomePage-main] Silgam ads shown',
      properties: {
        'title': ads.title,
        'actionIntents': ads.actions.map((e) => e.intent.toString()).join(', '),
        'actionData': ads.actions.map((e) => e.data).join(', '),
        'priority': ads.priority,
        'order': index + 1,
      },
    );
  }
}
