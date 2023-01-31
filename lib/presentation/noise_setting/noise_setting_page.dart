import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/noise_repository.dart';
import '../../util/const.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/custom_menu_bar.dart';
import '../home_page/settings/setting_tile.dart';
import '../purchase_page/purchase_page.dart';
import 'cubit/noise_setting_cubit.dart';

class NoiseSettingPage extends StatefulWidget {
  static const routeName = '/noise_setting';

  const NoiseSettingPage({Key? key}) : super(key: key);

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
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            '실제 시험장에서 나는 소음들을 백색 소음과 함께 랜덤하게 재생하여 더욱 실감나는 실전 연습을 돕습니다.',
            style: TextStyle(height: 1.35, color: Colors.grey.shade800),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            '아래의 추천 설정값을 사용하거나 소음들의 재생 빈도를 직접 설정할 수도 있습니다.',
            style: TextStyle(height: 1.35, color: Colors.grey.shade800),
          ),
        ),
        const SizedBox(height: 18),
        const Divider(height: 0.1),
        RadioListTile(
          onChanged: _cubit.onPresetChanged,
          value: NoisePreset.disabled,
          groupValue: state.selectedNoisePreset,
          title: const Text(
            '사용 안함',
            style: settingTitleTextStyle,
          ),
        ),
        RadioListTile(
          onChanged: _cubit.onPresetChanged,
          value: NoisePreset.easy,
          groupValue: state.selectedNoisePreset,
          title: const Text(
            '조용한 분위기',
            style: settingTitleTextStyle,
          ),
          subtitle: const Text(
            '실제 시험장보다 조용한 분위기로 편하게 연습할 수 있습니다.',
            style: settingDescriptionTextStyle,
          ),
        ),
        RadioListTile(
          onChanged: _cubit.onPresetChanged,
          value: NoisePreset.normal,
          groupValue: state.selectedNoisePreset,
          title: const Text(
            '시험장 분위기',
            style: settingTitleTextStyle,
          ),
          subtitle: const Text(
            '실제 시험장과 가장 유사한 분위기로 시험장에 와 있는 듯한 긴장감을 느낄 수 있습니다.',
            style: settingDescriptionTextStyle,
          ),
        ),
        RadioListTile(
          onChanged: _cubit.onPresetChanged,
          value: NoisePreset.hard,
          groupValue: state.selectedNoisePreset,
          title: const Text(
            '시끄러운 분위기',
            style: settingTitleTextStyle,
          ),
          subtitle: const Text(
            '실제 시험장보다 시끄러운 분위기로 모래주머니 효과를 원하는 분들에게 추천합니다.',
            style: settingDescriptionTextStyle,
          ),
        ),
        RadioListTile(
          onChanged: _cubit.onPresetChanged,
          value: NoisePreset.custom,
          groupValue: state.selectedNoisePreset,
          title: const Text(
            '직접 설정',
            style: settingTitleTextStyle,
          ),
        ),
        const Divider(height: 1),
        SettingTile(
          title: '백색 소음',
          description: '백색 소음으로 집중력을 높이고 현장감을 살릴 수 있습니다.',
          preferenceKey: PreferenceKey.useWhiteNoise,
          onSwitchChanged: _cubit.onWhiteNoiseChanged,
          defaultValue: false,
        ),
        const Divider(height: 1),
        const SizedBox(height: 6),
        BlocBuilder<AppCubit, AppState>(
          buildWhen: (previous, current) =>
              previous.productBenefit != current.productBenefit,
          builder: (context, appState) {
            final availableNoiseIds = appState.productBenefit.availableNoiseIds;
            return Column(
              children: [
                ...defaultNoises
                    .where((element) => availableNoiseIds.contains(element.id))
                    .map((noise) => _buildNoiseSettingTile(
                          noise,
                          isLocked: false,
                        ))
                    .toList(),
                ...defaultNoises
                    .where((element) => !availableNoiseIds.contains(element.id))
                    .map((noise) =>
                        _buildNoiseSettingTile(noise, isLocked: true))
                    .toList(),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildNoiseSettingTile(Noise noise, {required bool isLocked}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (noise.existingFiles == 0 ? '(지원 예정) ' : '') + noise.name,
                style: TextStyle(
                  color: noise.existingFiles == 0 ? Colors.grey : null,
                ),
              ),
              Slider(
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
            ],
          ),
        ),
        if (isLocked)
          Positioned.fill(
            child: InkWell(
              onTap: _onLockedNoiseTapped,
              splashColor: Colors.transparent,
              child: Container(
                color: Colors.black.withAlpha(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(
                      PurchasePage.routeName,
                      arguments: PurchasePageArguments(
                        product: iapState.activeProducts.first,
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
