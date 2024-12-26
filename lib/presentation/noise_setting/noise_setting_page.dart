import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/noise/noise_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/const.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/custom_menu_bar.dart';
import '../common/subtitle.dart';
import '../home/settings/setting_tile.dart';
import '../home/settings/settings_view.dart';
import '../purchase/purchase_page.dart';
import 'cubit/noise_setting_cubit.dart';

class NoiseSettingPage extends StatefulWidget {
  static const routeName = '/noise_setting';

  const NoiseSettingPage({super.key});

  @override
  State<NoiseSettingPage> createState() => _NoiseSettingPageState();
}

class _NoiseSettingPageState extends State<NoiseSettingPage> {
  final NoiseSettingCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const CustomMenuBar(title: '백색 소음, 시험장 소음 설정'),
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<NoiseSettingCubit, NoiseSettingState>(
                    builder: (context, state) {
                      return _buildSettingBody(state);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingBody(NoiseSettingState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            '실제 시험장에서 나는 소음들을 백색 소음과 함께 랜덤하게 재생하여 더욱 실감나는 실전 연습을 도와요.',
            style: TextStyle(height: 1.35, color: Colors.grey.shade800),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            '아래의 테마를 사용하거나 소음들의 재생 빈도를 직접 설정할 수도 있어요.',
            style: TextStyle(height: 1.35, color: Colors.grey.shade800),
          ),
        ),
        const SizedBox(height: 18),
        const Subtitle(text: '테마 모드'),
        const SizedBox(height: 6),
        _buildPresetButton(NoisePreset.disabled),
        _buildPresetButton(NoisePreset.easy),
        _buildPresetButton(NoisePreset.normal),
        _buildPresetButton(NoisePreset.hard),
        const SizedBox(height: 12),
        const Subtitle(text: '커스텀 모드'),
        const SizedBox(height: 6),
        SettingTile(
          title: '백색 소음',
          description: '백색 소음으로 집중력을 높이고 현장감을 살릴 수 있어요.',
          preferenceKey: PreferenceKey.useWhiteNoise,
          onSwitchChanged: _cubit.onWhiteNoiseChanged,
          defaultValue: false,
          paddingHorizontal: 28,
        ),
        const SettingDivider(),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            '여러가지 소음의 빈도를 조절할 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildNoiseSettings(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPresetButton(NoisePreset preset) {
    final isSelected = _cubit.state.selectedNoisePreset == preset;
    return GestureDetector(
      onTap: () => _cubit.onPresetChanged(preset),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          image: preset.backgroundImage != null
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(preset.backgroundImage ?? ''),
                )
              : null,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withAlpha(0),
                    ]
                  : [
                      const Color(0xFF303030),
                      const Color(0xFF303030).withAlpha(0),
                    ],
            ),
          ),
          child: Row(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isSelected ? 1 : 0,
                child: const Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          preset.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        for (int i = 0; i < preset.difficulty; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Image.asset(
                              'assets/star.png',
                              width: 13,
                              color: const Color(0xFFFFC700),
                            ),
                          ),
                        for (int i = 0; i < 5 - preset.difficulty; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Image.asset(
                              'assets/star.png',
                              width: 13,
                              color: const Color(0xFF767676),
                            ),
                          ),
                      ],
                    ),
                    if (preset.description != null) const SizedBox(height: 4),
                    if (preset.description != null)
                      Text(
                        preset.description ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoiseSettings() {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          previous.productBenefit != current.productBenefit,
      builder: (context, appState) {
        final availableNoiseIds = appState.productBenefit.availableNoiseIds;
        final noiseSettingWidgets = [
          ...defaultNoises
              .where((element) => availableNoiseIds.contains(element.id))
              .map((noise) => _buildNoiseSettingTile(
                    noise,
                    isLocked: false,
                  )),
          ...defaultNoises
              .where((element) => !availableNoiseIds.contains(element.id))
              .map((noise) => _buildNoiseSettingTile(noise, isLocked: true)),
        ];
        if (MediaQuery.of(context).size.width > 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: noiseSettingWidgets.sublist(
                    0,
                    (noiseSettingWidgets.length / 2).ceil(),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: noiseSettingWidgets.sublist(
                    (noiseSettingWidgets.length / 2).ceil(),
                    noiseSettingWidgets.length,
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          children: noiseSettingWidgets,
        );
      },
    );
  }

  Widget _buildNoiseSettingTile(Noise noise, {required bool isLocked}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  (noise.existingFiles == 0 ? '(지원 예정) ' : '') + noise.name,
                  style: TextStyle(
                    color: noise.existingFiles == 0 ? Colors.grey : null,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  trackShape: const RoundedRectSliderTrackShape(),
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: _cubit.state.noiseLevels[noise.id]?.toDouble() ?? 0,
                  onChanged: (value) =>
                      _cubit.onSliderChanged(noise, value.toInt()),
                  label: (_cubit.state.noiseLevels[noise.id]?.toDouble() ?? 0)
                      .toStringAsFixed(0),
                  max: Noise.maxLevel.toDouble(),
                  activeColor: Theme.of(context)
                      .primaryColor
                      .withAlpha(noise.existingFiles == 0 ? 80 : 255),
                  inactiveColor: noise.existingFiles == 0
                      ? Theme.of(context).primaryColor.withAlpha(20)
                      : null,
                ),
              ),
            ],
          ),
        ),
        if (isLocked)
          Positioned.fill(
            child: GestureDetector(
              onTap: _onLockedNoiseTapped,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '유료 기능',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onLockedNoiseTapped() {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: '${NoiseSettingPage.routeName}/locked_noise_info_dialog',
      ),
      builder: (context) {
        return BlocBuilder<IapCubit, IapState>(
          builder: (context, iapState) {
            final sellingProduct = iapState.sellingProduct;
            return AlertDialog(
              content: const Text('실감패스 사용자만 이용 가능한 소음이에요.'),
              contentPadding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 0,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text('확인'),
                ),
                if (sellingProduct != null)
                  TextButton(
                    onPressed: () {
                      AnalyticsManager.logEvent(
                        name: '[NoiseSettingPage] Check pass button tapped',
                      );
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                        PurchasePage.routeName,
                        arguments: PurchasePageArguments(
                          product: sellingProduct,
                        ),
                      );
                    },
                    child: const Text('실감패스 확인하러 가기'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
