import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
        body: Stack(
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
                margin: const EdgeInsets.all(8),
                child: IconButton(
                  onPressed: _onCloseButtonPressed,
                  icon: const Icon(Icons.arrow_back),
                  splashRadius: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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
              fontWeight: FontWeight.w700,
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
                onTap: _onGoogleLoginTapped,
                assetName: 'assets/google_icon.svg',
                provider: '구글',
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              _LoginButton(
                onTap: _onFacebookLoginTapped,
                assetName: 'assets/facebook_icon.svg',
                provider: '페이스북',
                color: const Color(0xFF4267b2),
                lightText: true,
              ),
              if (Platform.isIOS) const SizedBox(height: 12),
              if (Platform.isIOS)
                _LoginButton(
                  onTap: _onAppleLoginTapped,
                  assetName: 'assets/apple_icon.svg',
                  provider: '애플',
                  color: Colors.black,
                  lightText: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _onCloseButtonPressed() {
    Navigator.pop(context);
  }

  void _onGoogleLoginTapped() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    _loginFinished();
  }

  void _onFacebookLoginTapped() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final AccessToken? accessToken = loginResult.accessToken;
    if (accessToken == null) return;
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    _loginFinished();
  }

  void _onAppleLoginTapped() async {
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
    _loginFinished();
  }

  void _loginFinished() {
    final String? userName = FirebaseAuth.instance.currentUser?.displayName;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$userName님 반갑습니다!'),
    ));
    Navigator.pop(context);
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
                SizedBox(
                  width: 24,
                  child: SvgPicture.asset(assetName, height: 24),
                ),
                Expanded(
                  child: Text(
                    '$provider 로그인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: lightText ? Colors.white : Colors.black,
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
