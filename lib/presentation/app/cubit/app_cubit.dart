import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/product.dart';
import '../../../model/user.dart';
import '../../../repository/user/user_repository.dart';
import '../../../util/injection.dart';
import 'iap_cubit.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

const _preferenceKeyMe = 'me';

@lazySingleton
class AppCubit extends Cubit<AppState> {
  AppCubit(this._userRepository, this._sharedPreferences)
      : super(const AppState());

  final UserRepository _userRepository;
  final SharedPreferences _sharedPreferences;
  late final IapCubit _iapCubit = getIt.get();

  void initialize() {
    onUserChange();

    final cachedMe = _sharedPreferences.getString(_preferenceKeyMe);
    if (cachedMe != null) {
      log('Set user from cache: $cachedMe', name: 'AppCubit');
      emit(state.copyWith(me: User.fromJson(jsonDecode(cachedMe))));

      updateProductBenefit();
    }

    FirebaseAuth.instance.userChanges().skip(1).listen((user) async {
      await onUserChange();
    });
  }

  Future<void> onUserChange() async {
    final getMeResult = await _userRepository.getMe();
    final me = getMeResult.tryGetSuccess();

    if (me == null) {
      await _sharedPreferences.remove(_preferenceKeyMe);
    } else {
      await _sharedPreferences.setString(_preferenceKeyMe, jsonEncode(me));
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

    emit(state.copyWith(productBenefit: productBenefit));
    log('Update product benefit: ${state.productBenefit}', name: 'AppCubit');
  }
}
