import 'package:flutter/material.dart';

import '../../../util/injection.dart';
import '../../../util/string_util.dart';
import '../cubit/onboarding_cubit.dart';

class WelcomeView extends StatelessWidget {
  WelcomeView({super.key});

  final OnboardingCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/landing_background.png',
            fit: BoxFit.cover,
            alignment: const Alignment(-0.5, 0),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Text(
                    '👋 반가워요',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    keepWord('수능 실전 감각 연습, 오답노트, 성적관리까지 모두 실감과 함께 해보세요'),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.3,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(
                    height: 60,
                    color: Colors.white38,
                  ),
                  _buildButton(
                    onTap: _cubit.next,
                    text: '실감을 처음 써봐요!',
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _cubit.skip,
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '실감을 써본 적이 있어요',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required GestureTapCallback onTap,
    required String text,
    required Color? backgroundColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.grey.withAlpha(60),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
