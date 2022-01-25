import 'package:flutter/material.dart';

import '../../repository/noise_repository.dart';
import '../../util/shared_preferences_holder.dart';
import 'setting_tile.dart';

class NoiseSettingPage extends StatefulWidget {
  static const routeName = '/noise_setting';

  const NoiseSettingPage({Key? key}) : super(key: key);

  @override
  _NoiseSettingPageState createState() => _NoiseSettingPageState();
}

class _NoiseSettingPageState extends State<NoiseSettingPage> {
  NoisePreset _noisePreset = NoisePreset.disabled;
  bool _useWhiteNoise = false;
  final Map<int, int> _noiseLevels = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  splashRadius: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '백색 소음, 시험장 소음 설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      onChanged: _onPresetChanged,
                      value: NoisePreset.disabled,
                      groupValue: _noisePreset,
                      title: const Text(
                        '사용 안함',
                        style: settingTitleTextStyle,
                      ),
                    ),
                    RadioListTile(
                      onChanged: _onPresetChanged,
                      value: NoisePreset.easy,
                      groupValue: _noisePreset,
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
                      groupValue: _noisePreset,
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
                      groupValue: _noisePreset,
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
                      groupValue: _noisePreset,
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
                    const Divider(indent: 20, endIndent: 20),
                    const SizedBox(height: 4),
                    for (Noise noise in defaultNoises)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(noise.name),
                            Slider(
                              value: _noiseLevels[noise.id]?.toDouble() ?? 0,
                              onChanged: (value) => _onSliderChanged(noise, value.toInt()),
                              max: 10,
                              label: (_noiseLevels[noise.id]?.toDouble() ?? 0).toStringAsFixed(0),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPresetChanged(NoisePreset? preset) {
    _noisePreset = preset ?? NoisePreset.disabled;
    if (preset == NoisePreset.custom) return;
    for (Noise defaultNoise in defaultNoises) {
      _noiseLevels[defaultNoise.id] = defaultNoise.getDefaultLevel(_noisePreset);
    }
    _useWhiteNoise = preset != NoisePreset.disabled;
    _saveAll();
    setState(() {});
  }

  void _onWhiteNoiseChanged(bool isEnabled) {
    _noisePreset = NoisePreset.custom;
    _useWhiteNoise = isEnabled;
    _saveAll();
    setState(() {});
  }

  void _onSliderChanged(Noise noise, int value) {
    if (_noiseLevels[noise.id] == value) return;
    _noiseLevels[noise.id] = value;
    _noisePreset = NoisePreset.custom;
    _saveAll();
    setState(() {});
  }

  void _loadAll() {
    final sharedPreferences = SharedPreferencesHolder.get;
    final presetName = sharedPreferences.getString(PreferenceKey.noisePreset) ?? NoisePreset.disabled.name;
    _noisePreset = NoisePreset.values.byName(presetName);
    _useWhiteNoise = sharedPreferences.getBool(PreferenceKey.useWhiteNoise) ?? false;
    for (Noise defaultNoise in defaultNoises) {
      final level = sharedPreferences.getInt(defaultNoise.preferenceKey) ?? 0;
      _noiseLevels[defaultNoise.id] = level;
    }
  }

  void _saveAll() {
    final sharedPreferences = SharedPreferencesHolder.get;
    sharedPreferences.setString(PreferenceKey.noisePreset, _noisePreset.name);
    sharedPreferences.setBool(PreferenceKey.useWhiteNoise, _useWhiteNoise);
    for (Noise defaultNoise in defaultNoises) {
      final level = _noiseLevels[defaultNoise.id] ?? 0;
      sharedPreferences.setInt(defaultNoise.preferenceKey, level);
    }
  }
}
