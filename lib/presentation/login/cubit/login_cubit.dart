import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../repository/auth/auth_repository.dart';
import '../../app/cubit/app_cubit.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._appCubit, this._authRepository) : super(const LoginState());

  final AppCubit _appCubit;
  final AuthRepository _authRepository;

  Future<void> onLoginButtonTap(Future<void> Function() loginFunction) async {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 로그인할 수 없어요.',
        dismissOnTap: true,
      );
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      await loginFunction();
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      log(e.toString(), name: 'LoginCubit');
    }
  }

  Future<void> loginKakao() async {
    final isAppInstalled = await isKakaoTalkInstalled();
    final OAuthToken oAuthToken;
    if (isAppInstalled) {
      oAuthToken = await UserApi.instance.loginWithKakaoTalk();
    } else {
      oAuthToken = await UserApi.instance.loginWithKakaoAccount();
    }

    final authKakaoResult = await _authRepository.authKakao(oAuthToken);
    final firebaseToken = authKakaoResult.tryGetSuccess();
    if (firebaseToken == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
  }

  Future<void> loginGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  Future<void> loginFacebook() async {
    String? rawNonce;
    final LoginResult loginResult;
    if (Platform.isIOS) {
      rawNonce = generateNonce();
      loginResult = await FacebookAuth.instance.login(
        nonce: rawNonce.toSha256(),
      );
    } else {
      loginResult = await FacebookAuth.instance.login();
    }

    final AccessToken? accessToken = loginResult.accessToken;
    if (loginResult.status != LoginStatus.success || accessToken == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final OAuthCredential facebookAuthCredential = Platform.isIOS
        ? OAuthCredential(
            providerId: 'facebook.com',
            signInMethod: 'oauth',
            idToken: accessToken.tokenString,
            rawNonce: rawNonce,
          )
        : FacebookAuthProvider.credential(accessToken.tokenString);
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<void> loginApple() async {
    final rawNonce = generateNonce();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: rawNonce.toSha256(),
    );
    final credential = OAuthProvider('apple.com').credential(
      accessToken: appleCredential.authorizationCode,
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.displayName == null) {
      await currentUser?.updateDisplayName(
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}');
    }
  }
}

extension on String {
  String toSha256() {
    final bytes = utf8.encode(this);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
