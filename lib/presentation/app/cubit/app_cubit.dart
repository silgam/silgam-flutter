import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/user.dart';
import '../../../repository/user/user_repository.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

@lazySingleton
class AppCubit extends Cubit<AppState> {
  AppCubit(this._userRepository) : super(const AppState());

  final UserRepository _userRepository;

  Future<void> initialize() async {
    await onUserChange();
    FirebaseAuth.instance.userChanges().skip(1).listen((user) async {
      await onUserChange();
    });
  }

  Future<void> onUserChange() async {
    final me = await _userRepository.getMe();
    updateFcmToken(updatedMe: me, previousMe: state.me);
    emit(state.copyWith(me: me));
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
}
