import 'package:flutter/material.dart';

import '../../repository/noise_repository.dart';
import '../../util/menu_bar.dart';
import '../../util/shared_preferences_holder.dart';
import 'setting_tile.dart';

class NoiseSettingPage extends StatefulWidget {
  static const routeName = '/noise_setting';

  const NoiseSettingPage({Key? key}) : super(key: key);

  @override
  State<NoiseSettingPage> createState() => _NoiseSettingPageState();
}

class _NoiseSettingPageState extends State<NoiseSettingPage> {
  final NoiseSettings _noiseSettings = NoiseSettings();

  @override
  void initState() {
    super.initState();
    _noiseSettings.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MenuBar(title: '백색 소음, 시험장 소음 설정'),
            Expanded(
              child: SingleChildScrollView(
                child: _buildSettingBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 36),
        Image.asset('assets/phone_ringing_illustration.png'),
        const SizedBox(height: 36),
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
          onChanged: _onPresetChanged,
          value: NoisePreset.disabled,
          groupValue: _noiseSettings.noisePreset,
          title: const Text(
            '사용 안함',
            style: settingTitleTextStyle,
          ),
        ),
        RadioListTile(
          onChanged: _onPresetChanged,
          value: NoisePreset.easy,
          groupValue: _noiseSettings.noisePreset,
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
          onChanged: _onPresetChanged,
          value: NoisePreset.normal,
          groupValue: _noiseSettings.noisePreset,
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
          onChanged: _onPresetChanged,
          value: NoisePreset.hard,
          groupValue: _noiseSettings.noisePreset,
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
          onChanged: _onPresetChanged,
          value: NoisePreset.custom,
          groupValue: _noiseSettings.noisePreset,
          title: const Text(
            '직접 설정',
            style: settingTitleTextStyle,
          ),
        ),
        const Divider(),
        SettingTile(
          title: '백색 소음',
          description: '백색 소음으로 집중력을 높이고 현장감을 살릴 수 있습니다.',
          preferenceKey: PreferenceKey.useWhiteNoise,
          onSwitchChanged: _onWhiteNoiseChanged,
        ),
        const Divider(),
        const SizedBox(height: 4),
        for (Noise noise in defaultNoises)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                  value: _noiseSettings.noiseLevels[noise.id]?.toDouble() ?? 0,
                  onChanged: (value) => _onSliderChanged(noise, value.toInt()),
                  label: (_noiseSettings.noiseLevels[noise.id]?.toDouble() ?? 0).toStringAsFixed(0),
                  max: Noise.maxLevel.toDouble(),
                  divisions: Noise.maxLevel,
                  activeColor: Theme.of(context).primaryColor.withAlpha(noise.existingFiles == 0 ? 80 : 255),
                  inactiveColor: noise.existingFiles == 0 ? Theme.of(context).primaryColor.withAlpha(20) : null,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _onPresetChanged(NoisePreset? preset) {
    setState(() {
      _noiseSettings.noisePreset = preset ?? NoisePreset.disabled;
      if (preset == NoisePreset.custom) return;
      for (Noise defaultNoise in defaultNoises) {
        _noiseSettings.noiseLevels[defaultNoise.id] = defaultNoise.getDefaultLevel(_noiseSettings.noisePreset);
      }
      _noiseSettings.useWhiteNoise = preset != NoisePreset.disabled;
    });
    _noiseSettings.saveAll();
  }

  void _onWhiteNoiseChanged(bool isEnabled) {
    setState(() {
      _noiseSettings.noisePreset = NoisePreset.custom;
      _noiseSettings.useWhiteNoise = isEnabled;
    });
    _noiseSettings.saveAll();
  }

  void _onSliderChanged(Noise noise, int value) {
    setState(() {
      if (_noiseSettings.noiseLevels[noise.id] == value) return;
      _noiseSettings.noiseLevels[noise.id] = value;
      _noiseSettings.noisePreset = NoisePreset.custom;
    });
    _noiseSettings.saveAll();
  }
}
