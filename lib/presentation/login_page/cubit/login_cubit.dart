import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../repository/auth/auth_repository.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  Future<void> onLoginButtonTap(Future<void> Function() loginFunction) async {
    emit(state.copyWith(isProgressing: true));
    try {
      await loginFunction();
    } catch (e) {
      log(e.toString(), name: 'LoginCubit');
    } finally {
      emit(state.copyWith(isProgressing: false));
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
    final String firebaseToken =
        await _authRepository.getFirebaseToken(oAuthToken);
    await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
  }

  Future<void> loginGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> loginFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final AccessToken? accessToken = loginResult.accessToken;
    if (accessToken == null) return;
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(accessToken.token);
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
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.displayName == null) {
      await currentUser?.updateDisplayName(
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}');
    }
    if (currentUser?.email == null) {
      await currentUser?.updateEmail(appleCredential.email ?? '');
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
