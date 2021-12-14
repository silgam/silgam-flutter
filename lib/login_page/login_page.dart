import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
          const SizedBox(height: 40),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginButton(
                onTap: _onGoogleLoginTapped,
                assetName: 'assets/google_icon.svg',
              ),
              const SizedBox(width: 28),
              LoginButton(
                onTap: _onFaceLoginTapped,
                assetName: 'assets/facebook_icon.svg',
              ),
            ],
          ),
          const SizedBox(height: 12),
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

  void _onFaceLoginTapped() {}

  void _loginFinished() {
    final String? userName = FirebaseAuth.instance.currentUser?.displayName;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$userName님 반갑습니다!'),
    ));
    Navigator.pop(context);
  }
}

class LoginButton extends StatelessWidget {
  final String assetName;
  final GestureTapCallback onTap;

  const LoginButton({
    Key? key,
    required this.onTap,
    required this.assetName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              offset: const Offset(0, 1),
              blurRadius: 8,
            ),
          ],
        ),
        child: SvgPicture.asset(assetName, width: 48),
      ),
    );
  }
}
