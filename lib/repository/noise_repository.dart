enum NoisePreset { disabled, easy, normal, hard, custom }

class Noise {
  final int id;
  final String name;
  final String preferenceKey;
  final Map<NoisePreset, int> presetLevels;

  Noise({
    required this.id,
    required this.name,
    required this.preferenceKey,
    required this.presetLevels,
  });

  int getDefaultLevel(NoisePreset currentPreset) {
    return presetLevels[currentPreset] ?? 0;
  }
}

final defaultNoises = [
  Noise(
    id: 0,
    name: '시험지 넘기는 소리',
    preferenceKey: 'paperFlippingNoise',
    presetLevels: {
      NoisePreset.easy: 3,
      NoisePreset.normal: 5,
      NoisePreset.hard: 7,
    },
  ),
  Noise(
    id: 1,
    name: '기침 소리',
    preferenceKey: 'coughNoise',
    presetLevels: {
      NoisePreset.easy: 2,
      NoisePreset.normal: 3,
      NoisePreset.hard: 4,
    },
  ),
  Noise(
    id: 2,
    name: '글씨 쓰는 소리',
    preferenceKey: 'writingNoise',
    presetLevels: {
      NoisePreset.easy: 2,
      NoisePreset.normal: 3,
      NoisePreset.hard: 4,
    },
  ),
  Noise(
    id: 3,
    name: '지우개로 지우는 소리',
    preferenceKey: 'erasingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
  ),
  Noise(
    id: 4,
    name: '샤프 딸깍하는 소리',
    preferenceKey: 'sharpClickingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 2,
      NoisePreset.hard: 3,
    },
  ),
  Noise(
    id: 5,
    name: '코 훌쩍이는 소리',
    preferenceKey: 'sniffleNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 1,
      NoisePreset.hard: 2,
    },
  ),
  Noise(
    id: 6,
    name: '다리 떠는 소리',
    preferenceKey: 'legShakingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 1,
      NoisePreset.hard: 2,
    },
  ),
  Noise(
    id: 7,
    name: '옷 부딪히는 소리',
    preferenceKey: 'clothesNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 1,
      NoisePreset.hard: 2,
    },
  ),
  Noise(
    id: 8,
    name: '의자 움직이는 소리',
    preferenceKey: 'chairMovingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 1,
      NoisePreset.hard: 2,
    },
  ),
  Noise(
    id: 9,
    name: '의자 삐걱이는 소리',
    preferenceKey: 'chairCreakingNoise',
    presetLevels: {
      NoisePreset.easy: 1,
      NoisePreset.normal: 1,
      NoisePreset.hard: 2,
    },
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
  ),
];
