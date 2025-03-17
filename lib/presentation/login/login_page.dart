import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/analytics_manager.dart';
import '../../util/const.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import 'cubit/login_cubit.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginCubit _cubit = getIt.get();

  Widget _buildLoginLayout() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 72),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('3초만에 가입 / 로그인', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text(
            '로그인하면 실감의 더 많은 기능들을 이용할 수 있어요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              _LoginButton(
                onTap: () => _cubit.onLoginButtonTap(_cubit.loginKakao),
                assetName: 'assets/kakao_icon.svg',
                provider: '카카오',
                color: const Color(0xFFFEE500),
              ),
              const SizedBox(height: 12),
              _LoginButton(
                onTap: () => _cubit.onLoginButtonTap(_cubit.loginGoogle),
                assetName: 'assets/google_icon.svg',
                provider: '구글',
                color: Colors.white,
                borderColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 12),
              _LoginButton(
                onTap: () => _cubit.onLoginButtonTap(_cubit.loginFacebook),
                assetName: 'assets/facebook_icon.svg',
                provider: '페이스북',
                color: const Color(0xFF4267b2),
                lightText: true,
              ),
              if (!kIsWeb && Platform.isIOS) const SizedBox(height: 12),
              if (!kIsWeb && Platform.isIOS)
                _LoginButton(
                  onTap: () => _cubit.onLoginButtonTap(_cubit.loginApple),
                  assetName: 'assets/apple_icon.svg',
                  provider: 'Apple',
                  color: Colors.black,
                  lightText: true,
                ),
              const SizedBox(height: 16),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                  ),
                  children: [
                    const TextSpan(text: '로그인하면 '),
                    TextSpan(
                      text: '개인정보처리방침',
                      style: const TextStyle(color: Colors.blueAccent),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse(urlPrivacy),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                    ),
                    const TextSpan(text: ' 및 '),
                    TextSpan(
                      text: '서비스이용약관',
                      style: const TextStyle(color: Colors.blueAccent),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(urlTerms), mode: LaunchMode.externalApplication);
                            },
                    ),
                    const TextSpan(text: '에 동의하는 것으로 간주됩니다.'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) => previous.isSignedIn != current.isSignedIn,
      listener: (context, appState) {
        if (appState.isSignedIn) {
          Navigator.pop(context);
          EasyLoading.dismiss();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${appState.me!.displayName ?? '실감이'}님 반갑습니다!')));
          AnalyticsManager.logEvent(
            name: '[LoginPage] Login',
            properties: {'user_id': appState.me!.id},
          );
        }
      },
      child: BlocProvider(
        create: (context) => _cubit,
        child: PageLayout(
          onBackPressed: () => Navigator.pop(context),
          backgroundColor: Theme.of(context).primaryColor,
          textBrightness: Brightness.light,
          child: BlocConsumer<LoginCubit, LoginState>(
            listenWhen: (previous, current) => previous.isLoading != current.isLoading,
            listener: (context, state) {
              if (state.isLoading) {
                EasyLoading.show();
              } else {
                EasyLoading.dismiss();
              }
            },
            builder: (context, state) {
              return PopScope(
                canPop: !state.isLoading,
                child: Center(child: SingleChildScrollView(child: _buildLoginLayout())),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onTap,
    required this.assetName,
    required this.provider,
    required this.color,
    this.lightText = false,
    Color? borderColor,
  }) : borderColor = borderColor ?? color;

  final String assetName, provider;
  final Color color;
  final Color borderColor;
  final bool lightText;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
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
                    colorFilter:
                        lightText ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
                  ),
                ),
                Expanded(
                  child: Text(
                    '$provider로 계속하기',
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
