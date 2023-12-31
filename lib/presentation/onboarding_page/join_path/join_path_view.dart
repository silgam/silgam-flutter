import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/join_path.dart';
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
  final TextEditingController _otherJoinPathController =
      TextEditingController();

  void _onNextClick() {
    _cubit.submitJoinPath(otherJoinPath: _otherJoinPathController.text);
  }

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
                  onTap: _onNextClick,
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
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🤔',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 72,
              ),
            ),
            const Text(
              '실감을 어떻게 알게 되었나요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              '복수 선택 가능',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ...state.joinPaths
                .groupListsBy((path) => path.sectionTitle)
                .entries
                .map(
                  (entry) => _buildJoinPathSection(
                    title: entry.key,
                    joinPaths: entry.value,
                  ),
                ),
            _buildJoinPathSectionTitle('그 외 경로'),
            TextField(
              controller: _otherJoinPathController,
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
    );
  }

  Widget _buildJoinPathSection({
    required String title,
    required List<JoinPath> joinPaths,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildJoinPathSectionTitle(title),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...joinPaths.map(
              (joinPath) => _buildJoinPathChip(
                text: joinPath.text,
                onSelected: (selected) => _cubit.onJoinPathClicked(joinPath),
                selected:
                    _cubit.state.selectedJoinPathIds.contains(joinPath.id),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildJoinPathSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade900,
          height: 1.3,
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
