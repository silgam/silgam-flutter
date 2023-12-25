import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../util/injection.dart';
import '../../app/app.dart';
import '../cubit/onboarding_cubit.dart';

class JoinPathView extends StatefulWidget {
  const JoinPathView({super.key});

  @override
  State<JoinPathView> createState() => _JoinPathViewState();
}

class _JoinPathViewState extends State<JoinPathView> {
  final OnboardingCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: defaultSystemUiOverlayStyle,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: _buildScrollableSection(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildButton(
                  onTap: _cubit.next,
                  text: '시작하기',
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableSection() {
    return Column(
      children: [
        const Text(
          '🤔',
          style: TextStyle(
            fontSize: 72,
          ),
        ),
        const Text(
          '실감을 어떻게 알게 되었나요?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 60),
        const Text(
          '복수 선택 가능',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return Wrap(
              spacing: 8,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ...state.joinPaths.map(
                  (joinPath) => _buildJoinPathChip(
                    text: joinPath.text,
                    onSelected: (selected) =>
                        _cubit.onJoinPathClicked(joinPath),
                    selected:
                        _cubit.state.selectedJoinPathIds.contains(joinPath.id),
                  ),
                ),
                TextField(
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.3,
                  ),
                  decoration: InputDecoration(
                    hintText: '기타',
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildJoinPathChip({
    required String text,
    required ValueChanged<bool> onSelected,
    bool selected = false,
  }) {
    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      elevation: 0,
      pressElevation: 0,
      showCheckmark: false,
      selectedColor: Theme.of(context).primaryColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? Colors.transparent : Colors.grey.shade300,
        width: 1,
      ),
      label: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
