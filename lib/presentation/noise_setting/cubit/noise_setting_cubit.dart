import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../repository/noise/noise_repository.dart';
import '../../../util/analytics_manager.dart';
import '../../../util/const.dart';

part 'noise_setting_cubit.freezed.dart';
part 'noise_setting_state.dart';

@lazySingleton
class NoiseSettingCubit extends Cubit<NoiseSettingState> {
  NoiseSettingCubit(this._sharedPreferences) : super(const NoiseSettingState()) {
    _loadAll();
  }

  final SharedPreferences _sharedPreferences;

  void onPresetChanged(NoisePreset? preset) {
    final noisePreset = preset ?? NoisePreset.disabled;
    if (preset == NoisePreset.custom) return;

    final useWhiteNoise = preset != NoisePreset.disabled;

    final noiseLevels = <int, int>{};
    for (Noise defaultNoise in defaultNoises) {
      noiseLevels[defaultNoise.id] = defaultNoise.getDefaultLevel(noisePreset);
    }

    emit(
      state.copyWith(
        selectedNoisePreset: noisePreset,
        useWhiteNoise: useWhiteNoise,
        noiseLevels: noiseLevels,
      ),
    );
    _saveAll();

    AnalyticsManager.logEvent(
      name: '[NoiseSettingPage] Noise preset changed',
      properties: {'preset': state.selectedNoisePreset.name},
    );
    AnalyticsManager.setPeopleProperty('[Noise] Preset', state.selectedNoisePreset.name);
  }

  void onWhiteNoiseChanged(bool isEnabled) {
    emit(state.copyWith(selectedNoisePreset: NoisePreset.custom, useWhiteNoise: isEnabled));
    _saveAll();

    AnalyticsManager.logEvent(
      name: '[NoiseSettingPage] White noise changed',
      properties: {'enabled': state.useWhiteNoise},
    );
    AnalyticsManager.setPeopleProperty('[Noise] Use White Noise', state.useWhiteNoise);
  }

  void onSliderChanged(Noise noise, int value) {
    if (state.noiseLevels[noise.id] == value) return;

    emit(
      state.copyWith(
        selectedNoisePreset: NoisePreset.custom,
        noiseLevels: {...state.noiseLevels, noise.id: value},
      ),
    );
    _saveAll();

    AnalyticsManager.logEvent(
      name: '[NoiseSettingPage] Noise level changed',
      properties: {'noise': noise.name, 'level': value},
    );
    AnalyticsManager.setPeopleProperty('[Noise] Levels', state.noiseLevels.toString());
  }

  void _loadAll() {
    final presetName =
        _sharedPreferences.getString(PreferenceKey.noisePreset) ?? NoisePreset.disabled.name;
    final noisePreset = NoisePreset.values.byName(presetName);
    final useWhiteNoise = _sharedPreferences.getBool(PreferenceKey.useWhiteNoise) ?? false;
    final noiseLevels = <int, int>{};
    for (Noise defaultNoise in defaultNoises) {
      final level = _sharedPreferences.getInt(defaultNoise.preferenceKey) ?? 0;
      noiseLevels[defaultNoise.id] = level;
    }

    emit(
      state.copyWith(
        selectedNoisePreset: noisePreset,
        useWhiteNoise: useWhiteNoise,
        noiseLevels: noiseLevels,
      ),
    );
  }

  void _saveAll() {
    _sharedPreferences.setString(PreferenceKey.noisePreset, state.selectedNoisePreset.name);
    _sharedPreferences.setBool(PreferenceKey.useWhiteNoise, state.useWhiteNoise);
    for (Noise defaultNoise in defaultNoises) {
      final level = state.noiseLevels[defaultNoise.id] ?? 0;
      _sharedPreferences.setInt(defaultNoise.preferenceKey, level);
    }
  }
}
