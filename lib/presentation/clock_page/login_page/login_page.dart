import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../repository/auth_repository.dart';
import '../../../repository/user_repository.dart';
import '../../common/menu_bar.dart';
import '../../common/progress_overlay.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isProgressing = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Theme.of(context).primaryColor,
      ),
      child: Scaffold(
        body: ProgressOverlay(
          isProgressing: _isProgressing,
          fast: true,
          description: '로그인 하는 중입니다.',
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF3F50A8), Theme.of(context).primaryColor],
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildLoginLayout(),
              ),
              SafeArea(
                child: Container(
                  alignment: Alignment.topLeft,
                  child: const MenuBar(lightText: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLayout() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '로그인',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '로그인하면 실감의 더 많은 기능들을 누릴 수 있어요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              _LoginButton(
                onTap: () => _onLoginButtonTap(_loginKakao),
                assetName: 'assets/kakao_icon.svg',
                provider: '카카오',
                color: const Color(0xFFFEE500),
              ),
              const SizedBox(height: 12),
              _LoginButton(
                onTap: () => _onLoginButtonTap(_loginGoogle),
                assetName: 'assets/google_icon.svg',
                provider: '구글',
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              _LoginButton(
                onTap: () => _onLoginButtonTap(_loginFacebook),
                assetName: 'assets/facebook_icon.svg',
                provider: '페이스북',
                color: const Color(0xFF4267b2),
                lightText: true,
              ),
              if (Platform.isIOS) const SizedBox(height: 12),
              if (Platform.isIOS)
                _LoginButton(
                  onTap: () => _onLoginButtonTap(_loginApple),
                  assetName: 'assets/apple_icon.svg',
                  provider: 'Apple',
                  color: Colors.black,
                  lightText: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _onLoginButtonTap(Future<void> Function() loginFunction) async {
    _isProgressing = true;
    setState(() {});
    try {
      await loginFunction();
      final userRepository = UserRepository();
      if (userRepository.isNotSignedIn()) throw Exception('Not signed in');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${userRepository.getUser().displayName}님 반갑습니다!'),
        ));
        Navigator.pop(context);
      }
      await FirebaseAnalytics.instance.logEvent(
        name: 'login',
        parameters: {'user_id': userRepository.getUser().uid},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    } finally {
      _isProgressing = false;
      setState(() {});
    }
  }

  Future<void> _loginKakao() async {
    final isAppInstalled = await isKakaoTalkInstalled();
    final OAuthToken oAuthToken;
    if (isAppInstalled) {
      oAuthToken = await UserApi.instance.loginWithKakaoTalk();
    } else {
      oAuthToken = await UserApi.instance.loginWithKakaoAccount();
    }
    final String firebaseToken = await AuthRepository().getFirebaseToken(oAuthToken);
    await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
  }

  Future<void> _loginGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _loginFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final AccessToken? accessToken = loginResult.accessToken;
    if (accessToken == null) return;
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<void> _loginApple() async {
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
      await currentUser?.updateDisplayName('${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}');
    }
    if (currentUser?.email == null) {
      await currentUser?.updateEmail(appleCredential.email ?? '');
    }
  }
}

class _LoginButton extends StatelessWidget {
  final String assetName, provider;
  final Color color;
  final bool lightText;
  final GestureTapCallback onTap;

  const _LoginButton({
    Key? key,
    required this.onTap,
    required this.assetName,
    required this.provider,
    required this.color,
    this.lightText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(28),
            offset: const Offset(1, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.grey.withAlpha(60),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const SizedBox(width: 1),
                SizedBox(
                  width: 24,
                  child: SvgPicture.asset(
                    assetName,
                    height: 24,
                    color: lightText ? Colors.white : null,
                  ),
                ),
                Expanded(
                  child: Text(
                    '$provider 로그인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: lightText ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  String toSha256() {
    final bytes = utf8.encode(this);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
