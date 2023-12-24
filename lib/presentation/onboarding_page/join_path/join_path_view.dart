import 'package:flutter/material.dart';

import '../../../util/injection.dart';
import '../cubit/onboarding_cubit.dart';

class JoinPathView extends StatefulWidget {
  JoinPathView({super.key});

  final OnboardingCubit _cubit = getIt.get();

  @override
  State<JoinPathView> createState() => _JoinPathViewState();
}

class _JoinPathViewState extends State<JoinPathView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                '실감을 어떻게 알게 되었나요?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildJoinPathChip(
                    text: '인스타그램',
                    onSelected: (a) {},
                    selected: true,
                  ),
                  _buildJoinPathChip(
                    text: '페이스북',
                    onSelected: (a) {},
                  ),
                  _buildJoinPathChip(
                    text: '친구 추천',
                    onSelected: (a) {},
                  ),
                  _buildJoinPathChip(
                    text: '기타',
                    onSelected: (a) {},
                  ),
                  _buildJoinPathChip(
                    text: '기타',
                    onSelected: (a) {},
                  ),
                  _buildJoinPathChip(
                    text: '기타',
                    onSelected: (a) {},
                  ),
                ],
              ),
              const Spacer(),
              _buildButton(
                onTap: () {},
                text: '시작하기',
                backgroundColor: Theme.of(context).primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinPathChip({
    required String text,
    required ValueChanged<bool> onSelected,
    bool selected = false,
  }) {
    return FilterChip(
      label: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      elevation: 0,
      pressElevation: 0,
      showCheckmark: false,
      selectedColor: Theme.of(context).primaryColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
