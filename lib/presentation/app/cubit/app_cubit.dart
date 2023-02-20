import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/product.dart';
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

  Future<void> initialize() async {
    final connectivity = await Connectivity().checkConnectivity();
    onConnectivityChanged(connectivity);

    final cachedMe = _sharedPreferences.getString(PreferenceKey.cacheMe);
    if (cachedMe != null) {
      onUserChange();

      log('Set user from cache: $cachedMe', name: 'AppCubit');
      emit(state.copyWith(me: User.fromJson(jsonDecode(cachedMe))));

      updateProductBenefit();
    } else {
      await onUserChange();
    }

    FirebaseAuth.instance.userChanges().skip(1).listen((user) async {
      await onUserChange();
    });

    Connectivity().onConnectivityChanged.listen((connectivityResult) async {
      onConnectivityChanged(connectivityResult);
    });
  }

  Future<void> onUserChange() async {
    final getMeResult = await _userRepository.getMe();
    final me = getMeResult.tryGetSuccess();

    if (me == null) {
      AnalyticsManager.setPeopleProperty('[Product] Id', null);
      AnalyticsManager.setPeopleProperty('[Product] Purchased Store', null);
      await _sharedPreferences.remove(PreferenceKey.cacheMe);
    } else {
      AnalyticsManager.setPeopleProperty('[Product] Id', me.activeProduct.id);
      AnalyticsManager.setPeopleProperty(
        '[Product] Purchased Store',
        me.activeProduct.id != 'free' ? me.receipts.last.store : null,
      );
      await _sharedPreferences.setString(PreferenceKey.cacheMe, jsonEncode(me));
    }

    updateFcmToken(updatedMe: me, previousMe: state.me);
    emit(state.copyWith(me: me));

    updateProductBenefit();
  }

  Future<void> updateFcmToken({
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

  void updateProductBenefit() {
    final products = _iapCubit.state.products;
    final freeProduct = products.firstWhereOrNull((p) => p.id == 'free');
    final productBenefit = state.me?.activeProduct.benefit ??
        freeProduct?.benefit ??
        ProductBenefit.initial;

    emit(state.copyWith(
      productBenefit: productBenefit,
      freeProductBenefit: freeProduct?.benefit ?? ProductBenefit.initial,
    ));
    log('Update product benefit: ${state.productBenefit}', name: 'AppCubit');
  }

  void onConnectivityChanged(ConnectivityResult connectivityResult) {
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
}
