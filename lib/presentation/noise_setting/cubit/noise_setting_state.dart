part of 'noise_setting_cubit.dart';

@freezed
class NoiseSettingState with _$NoiseSettingState {
  const factory NoiseSettingState({
    @Default(NoisePreset.disabled) NoisePreset selectedNoisePreset,
    @Default(false) bool useWhiteNoise,
    @Default({}) Map<int, int> noiseLevels,
  }) = _NoiseSettingState;
}
