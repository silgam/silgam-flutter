import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../model/ads.dart';
import '../../../../model/dday.dart';
import '../../../../repository/ads/ads_repository.dart';
import '../../../../repository/dday/dday_repository.dart';
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
    final ads = _cacheManager.getAds();
    if (ads != null) updateAds(cachedAds: ads);

    _updateDDays();
    final dDays = _cacheManager.getDDays();
    if (dDays != null) _updateDDays(cachedDDays: dDays);
  }

  Future<void> updateAds({
    List<Ads>? cachedAds,
  }) async {
    List<Ads>? ads = cachedAds;
    if (cachedAds == null) {
      final getAdsResult = await _adsRepository.getAllAds();
      ads = getAdsResult.tryGetSuccess();
      await _cacheManager.setAds(ads);
    }
    ads ??= [];

    final isPurchasedUser = _appCubit.state.me?.isPurchasedUser ?? false;
    final isAdsRemoved = _appCubit.state.productBenefit.isAdsRemoved;
    emit(state.copyWith(
      ads: ads
          .whereNot((ad) =>
              (isPurchasedUser && ad.isHiddenToPurchasedUser) ||
              (isAdsRemoved && ad.isAd))
          .toList(),
    ));
  }

  Future<void> _updateDDays({
    List<DDay>? cachedDDays,
  }) async {
    List<DDay>? dDays = cachedDDays;
    if (cachedDDays == null) {
      final getDDaysResult = await _dDayRepository.getAllDDays();
      dDays = getDDaysResult.tryGetSuccess();
      await _cacheManager.setDDays(dDays);
    }
    dDays ??= [];

    final dDayItems = DDayUtil(dDays).getItemsToShow(DateTime.now());
    emit(state.copyWith(dDayItems: dDayItems));
  }
}
