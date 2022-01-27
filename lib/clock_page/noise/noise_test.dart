import '../../repository/noise_repository.dart';
import 'noise_generator.dart';
import 'noise_player.dart';

const Duration _testDuration = Duration(hours: 1);
const NoisePreset _noisePreset = NoisePreset.normal;

void main() async {
  final noiseGenerator = NoiseGenerator(
    noisePreset: _noisePreset,
    useWhiteNoise: true,
    noiseLevels: {
      for (Noise noise in defaultNoises) noise.id: noise.presetLevels[_noisePreset] ?? 0,
    },
    noisePlayer: NoisePlayerMock(),
  );
  noiseGenerator.start();
  print(
      '              시험지               글씨              지우개               샤프               기침               코                다리                옷                의자1              의자2             떨어지는');
  await Future.delayed(_testDuration, null);
}

class NoisePlayerMock implements NoisePlayer {
  @override
  void playNoise(int noiseId) {}

  @override
  void playWhiteNoise() {
    print('백색 소음 재생 시작');
  }
}
