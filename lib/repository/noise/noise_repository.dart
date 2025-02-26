import 'dart:math';

enum NoisePreset {
  disabled(title: '사용 안함', difficulty: 0),
  easy(
    title: '조용한 분위기',
    difficulty: 1,
    description: '실제 시험장보다 조용한 분위기로 편하게 연습할 수 있어요.',
    backgroundImage: 'assets/noise_easy.png',
  ),
  normal(
    title: '시험장 분위기',
    difficulty: 2,
    description: '실제 시험장과 가장 유사한 분위기로 시험장에 와 있는 듯한 긴장감을 느낄 수 있어요.',
    backgroundImage: 'assets/noise_normal.png',
  ),
  hard(
    title: '시끄러운 분위기',
    difficulty: 4,
    description: '실제 시험장보다 시끄러운 분위기로 모래주머니 효과를 원하는 분들에게 추천해요.',
    backgroundImage: 'assets/noise_hard.png',
  ),
  custom(title: '직접 설정', difficulty: 0);

  const NoisePreset({
    required this.title,
    required this.difficulty,
    this.description,
    this.backgroundImage,
  });

  final String title;
  final int difficulty;
  final String? description;
  final String? backgroundImage;
}

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
  }) : assert(existingFiles > 0, 'existingFiles must be greater than 0');

  String getRandomNoisePath() {
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
    existingFiles: 20,
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
