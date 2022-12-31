import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../util/const.dart';

enum NoisePreset { disabled, easy, normal, hard, custom }

class Noise {
  static const int maxLevel = 20;
  final int id;
  final String name;
  final String preferenceKey;
  final Map<NoisePreset, int> presetLevels;
  final int existingFiles;

  const Noise({
    required this.id,
    required this.name,
    required this.preferenceKey,
    required this.presetLevels,
    required this.existingFiles,
  });

  String? getRandomNoisePath() {
    if (existingFiles == 0) return null;
    int randomNumber = Random().nextInt(existingFiles) + 1;
    return '$_noiseAssetPath/$preferenceKey$randomNumber.mp3';
  }

  int getDefaultLevel(NoisePreset currentPreset) {
    return presetLevels[currentPreset] ?? 0;
  }

  static Noise byId(int id) {
    return defaultNoises.firstWhere((noise) => noise.id == id);
  }
}

class NoiseSettings {
  NoiseSettings(SharedPreferences sharedPreferences)
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  final Map<int, int> noiseLevels = {};
  NoisePreset noisePreset = NoisePreset.disabled;
  bool useWhiteNoise = false;

  void loadAll() {
    final presetName =
        _sharedPreferences.getString(PreferenceKey.noisePreset) ??
            NoisePreset.disabled.name;
    noisePreset = NoisePreset.values.byName(presetName);
    useWhiteNoise =
        _sharedPreferences.getBool(PreferenceKey.useWhiteNoise) ?? false;
    for (Noise defaultNoise in defaultNoises) {
      final level = _sharedPreferences.getInt(defaultNoise.preferenceKey) ?? 0;
      noiseLevels[defaultNoise.id] = level;
    }
  }

  void saveAll() {
    _sharedPreferences.setString(PreferenceKey.noisePreset, noisePreset.name);
    _sharedPreferences.setBool(PreferenceKey.useWhiteNoise, useWhiteNoise);
    for (Noise defaultNoise in defaultNoises) {
      final level = noiseLevels[defaultNoise.id] ?? 0;
      _sharedPreferences.setInt(defaultNoise.preferenceKey, level);
    }
  }
}

const _noiseAssetPath = 'assets/noises';
const whiteNoisePath = '$_noiseAssetPath/whiteNoise.mp3';
const defaultNoises = [
  Noise(
    id: 0,
    name: '시험지 넘기는 소리',
    preferenceKey: 'paperFlippingNoise',
    presetLevels: {
      NoisePreset.easy: 8,
      NoisePreset.normal: 12,
      NoisePreset.hard: 16,
    },
    existingFiles: 35,
  ),
  Noise(
    id: 1,
    name: '글씨 쓰는 소리',
    preferenceKey: 'writingNoise',
    presetLevels: {
      NoisePreset.easy: 6,
      NoisePreset.normal: 8,
      NoisePreset.hard: 10,
    },
    existingFiles: 15,
  ),
  Noise(
    id: 2,
    name: '지우개로 지우는 소리',
    preferenceKey: 'erasingNoise',
    presetLevels: {
      NoisePreset.easy: 2,
      NoisePreset.normal: 4,
      NoisePreset.hard: 6,
    },
    existingFiles: 10,
  ),
  Noise(
    id: 3,
    name: '샤프 딸깍하는 소리',
    preferenceKey: 'sharpClickingNoise',
    presetLevels: {
      NoisePreset.easy: 2,
      NoisePreset.normal: 4,
      NoisePreset.hard: 6,
    },
    existingFiles: 20,
  ),
  Noise(
    id: 4,
    name: '기침 소리 (남자)',
    preferenceKey: 'manCoughNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
    existingFiles: 25,
  ),
  Noise(
    id: 11,
    name: '기침 소리 (여자)',
    preferenceKey: 'womanCoughNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
    existingFiles: 30,
  ),
  Noise(
    id: 12,
    name: '한숨 소리',
    preferenceKey: 'sighNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
    existingFiles: 25,
  ),
  Noise(
    id: 5,
    name: '코 훌쩍이는 소리',
    preferenceKey: 'sniffleNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
    existingFiles: 25,
  ),
  Noise(
    id: 6,
    name: '다리 떠는 소리',
    preferenceKey: 'legShakingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
    existingFiles: 20,
  ),
  Noise(
    id: 7,
    name: '옷 부딪히는 소리',
    preferenceKey: 'clothesNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
    existingFiles: 20,
  ),
  Noise(
    id: 8,
    name: '의자 움직이는 소리',
    preferenceKey: 'chairMovingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
    existingFiles: 25,
  ),
  Noise(
    id: 9,
    name: '의자 삐걱이는 소리',
    preferenceKey: 'chairCreakingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
    existingFiles: 25,
  ),
  Noise(
    id: 10,
    name: '뭔가 바닥에 떨어지는 소리',
    preferenceKey: 'droppingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 1,
      NoisePreset.hard: 2,
    },
    existingFiles: 10,
  ),
];
