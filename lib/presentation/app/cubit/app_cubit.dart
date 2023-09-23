import 'dart:convert';
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
import '../../../util/analytics_manager.dart';
import '../../../util/const.dart';
import '../../../util/injection.dart';
import '../../home_page/main/cubit/main_cubit.dart';
import 'iap_cubit.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

@lazySingleton
class AppCubit extends Cubit<AppState> {
  AppCubit(this._userRepository, this._sharedPreferences)
      : super(const AppState());

  final UserRepository _userRepository;
  final SharedPreferences _sharedPreferences;
  late final IapCubit _iapCubit = getIt.get();

  bool get useLapTime =>
      (_sharedPreferences.getBool(PreferenceKey.useLapTime) ?? true) &&
      state.productBenefit.isLapTimeAvailable;

  Future<void> initialize() async {
    final connectivity = await Connectivity().checkConnectivity();
    _onConnectivityChanged(connectivity);

    _updateUser();

    FirebaseAuth.instance.userChanges().skip(1).listen((user) async {
      await onUserChange();
    });

    Connectivity().onConnectivityChanged.listen((connectivityResult) async {
      _onConnectivityChanged(connectivityResult);
    });
  }

  Future<void> onUserChange({
    User? cachedMe,
  }) async {
    User? me;
    if (cachedMe != null) {
      me = cachedMe;
    } else {
      final getMeResult = await _userRepository.getMe();
      me = getMeResult.tryGetSuccess();

      if (me == null) {
        AnalyticsManager.setPeopleProperty('[Product] Id', null);
        AnalyticsManager.setPeopleProperty('[Product] Purchased Store', null);
        AnalyticsManager.setPeopleProperty(
          'Marketing Info Receiving Consented',
          null,
        );
        await _sharedPreferences.remove(PreferenceKey.cacheMe);
      } else {
        AnalyticsManager.setPeopleProperty('[Product] Id', me.activeProduct.id);
        AnalyticsManager.setPeopleProperty(
          '[Product] Purchased Store',
          me.activeProduct.id != ProductId.free ? me.receipts.last.store : null,
        );
        AnalyticsManager.setPeopleProperty(
          'Marketing Info Receiving Consented',
          me.isMarketingInfoReceivingConsented,
        );
        await _sharedPreferences.setString(
            PreferenceKey.cacheMe, jsonEncode(me));
      }
      _updateFcmToken(updatedMe: me, previousMe: state.me);
    }

    emit(state.copyWith(me: me));

    updateProductBenefit();
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

  Future<void> _updateUser() async {
    User? cachedMe;
    try {
      cachedMe = _fetchUserFromCache();
    } catch (e) {
      log(
        'Failed to update user from cache: $e',
        name: runtimeType.toString(),
        error: e,
        stackTrace: StackTrace.current,
      );
    }
    if (cachedMe != null) {
      onUserChange();
      onUserChange(cachedMe: cachedMe);
    } else {
      await onUserChange();
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
    if (state.connectivityResult == ConnectivityResult.none &&
        connectivityResult != ConnectivityResult.none) {
      onUserChange();
      getIt.get<IapCubit>().initialize();
      getIt.get<MainCubit>().initialize();
    }

    emit(state.copyWith(
      connectivityResult: connectivityResult,
      me: connectivityResult == ConnectivityResult.none ? null : state.me,
    ));
  }

  User? _fetchUserFromCache() {
    final cachedMe = _sharedPreferences.getString(PreferenceKey.cacheMe);
    if (cachedMe == null) return null;

    log('Set user from cache: $cachedMe', name: runtimeType.toString());
    return User.fromJson(jsonDecode(cachedMe));
  }
}
