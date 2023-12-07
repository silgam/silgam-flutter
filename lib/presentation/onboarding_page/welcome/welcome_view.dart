import 'package:flutter/material.dart';

import '../cubit/onboarding_cubit.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView(
    this._cubit, {
    super.key,
  });

  final OnboardingCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                const Text(
                  '환영합니다',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '수능 실전 감각 연습, 오답노트, 성적관리까지 모두 실감에서 한 번에 관리해보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                Text(
                  '실감이 처음이신가요?',
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildButton(
                  onTap: _cubit.next,
                  text: '네! 처음이에요',
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _cubit.skip,
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: const Text('아니요, 써본 적 있어요'),
                ),
              ],
            ),
          ),
        ),
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
