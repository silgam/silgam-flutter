import 'dart:async';
import 'dart:math';

import '../../repository/noise_repository.dart';
import 'noise_player.dart';

class NoiseGenerator {
  static const double _probabilityMultiple = 0.001;
  final NoiseSettings noiseSettings;
  final NoisePlayer noisePlayer;
  final _random = Random();

  NoiseGenerator({
    required this.noiseSettings,
    required this.noisePlayer,
  });

  void start() {
    if (noiseSettings.useWhiteNoise) {
      noisePlayer.playWhiteNoise();
    }
    Timer.periodic(const Duration(milliseconds: 100), (_) {
      noiseSettings.noiseLevels.forEach((id, level) {
        if (_canPlay(level)) {
          noisePlayer.playNoise(id);
        }
      });
    });
  }

  bool _canPlay(int level) {
    return level * _probabilityMultiple > _random.nextDouble();
  }
}
