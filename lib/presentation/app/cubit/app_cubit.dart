import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/product.dart';
import '../../../model/subject.dart';
import '../../../model/user.dart';
import '../../../repository/user/user_repository.dart';
import '../../../util/api_failure.dart';
import '../../../util/cache_manager.dart';
import '../../../util/connectivity_manager.dart';
import '../../../util/const.dart';
import '../../../util/injection.dart';
import '../../home_page/main/cubit/main_cubit.dart';
import 'iap_cubit.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

@lazySingleton
class AppCubit extends Cubit<AppState> {
  AppCubit(
    this._userRepository,
    this._sharedPreferences,
    this._cacheManager,
    this._connectivityManger,
  ) : super(const AppState());

  final UserRepository _userRepository;
  final SharedPreferences _sharedPreferences;
  final CacheManager _cacheManager;
  final ConnectivityManger _connectivityManger;
  late final IapCubit _iapCubit = getIt.get();

  bool get useLapTime =>
      (_sharedPreferences.getBool(PreferenceKey.useLapTime) ?? true) &&
      state.productBenefit.isLapTimeAvailable;

  @override
  void onChange(Change<AppState> change) {
    if (change.nextState.me?.id != change.currentState.me?.id) {
      _connectivityManger.updateRealtimeDatabaseListener(
        userId: change.nextState.me?.id,
      );
    }
    super.onChange(change);
  }

  Future<void> initialize() async {
    final connectivity = await Connectivity().checkConnectivity();
    _onConnectivityChanged(connectivity);
    Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);

    _connectivityManger.updateRealtimeDatabaseListener(userId: state.me?.id);

    FirebaseAuth.instance.userChanges().listen((user) {
      onUserChange();
    });
  }

  Future<void> onUserChange() async {
    User? cachedMe = _cacheManager.getMe();
    emit(state.copyWith(me: cachedMe));
    updateProductBenefit();

    final getMeResult = await _userRepository.getMe();
    if (getMeResult.tryGetError()?.type == ApiFailureType.noNetwork) return;

    User? me = getMeResult.tryGetSuccess();
    await _cacheManager.setMe(me);
    _updateFcmToken(updatedMe: me, previousMe: state.me);
    emit(state.copyWith(me: me));
    updateProductBenefit();
  }

  Future<void> onLogout() async {
    await _cacheManager.setMe(null);
    _updateFcmToken(updatedMe: null, previousMe: state.me);
    emit(state.copyWith(me: null));
    updateProductBenefit();

    await FirebaseAuth.instance.signOut();
  }

  void updateProductBenefit() {
    final freeProductBenefit =
        _iapCubit.state.freeProduct?.benefit ?? ProductBenefit.initial;
    final productBenefit =
        state.me?.activeProduct.benefit ?? freeProductBenefit;

    emit(state.copyWith(
      productBenefit: productBenefit,
      freeProductBenefit: freeProductBenefit,
    ));
    log('Update product benefit: ${state.productBenefit}', name: 'AppCubit');
  }

  void updateIsOffline(bool isOffline) {
    if (state.isOffline != isOffline) {
      emit(state.copyWith(
        isOffline: isOffline,
      ));
      onUserChange();
      getIt.get<IapCubit>().initialize();
      getIt.get<MainCubit>().initialize();
    }
  }

  Future<void> _updateFcmToken({
    required User? updatedMe,
    required User? previousMe,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log('fcmToken: $fcmToken', name: 'AppCubit');
    if (fcmToken == null) return;

    if (updatedMe == null) {
      if (previousMe == null) return;

      if (previousMe.fcmTokens.contains(fcmToken)) {
        await _userRepository.removeFcmToken(
          userId: previousMe.id,
          fcmToken: fcmToken,
        );
        log('fcmToken removed', name: 'AppCubit');
      }
    } else {
      if (updatedMe.fcmTokens.contains(fcmToken)) return;

      await _userRepository.addFcmToken(
        userId: updatedMe.id,
        fcmToken: fcmToken,
      );
      emit(state.copyWith(
        me: updatedMe.copyWith(
          fcmTokens: [...updatedMe.fcmTokens, fcmToken],
        ),
      ));
      log('fcmToken added', name: 'AppCubit');
    }
  }

  void _onConnectivityChanged(ConnectivityResult connectivityResult) {
    log('Connectivity changed: $connectivityResult', name: 'AppCubit');
    final isOffline = connectivityResult == ConnectivityResult.none;
    updateIsOffline(isOffline);
  }
}
