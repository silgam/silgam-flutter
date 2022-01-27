import 'dart:async';
import 'dart:math';

import 'package:intl/intl.dart';

import '../../repository/noise_repository.dart';
import 'noise_player.dart';

class NoiseGenerator {
  static const double probabilityMultiple = 0.001;
  final NoisePreset noisePreset;
  final bool useWhiteNoise;
  final Map<int, int> noiseLevels;
  final NoisePlayer noisePlayer;
  final _random = Random();

  NoiseGenerator({
    required this.noisePreset,
    required this.useWhiteNoise,
    required this.noiseLevels,
    required this.noisePlayer,
  });

  void start() {
    if (useWhiteNoise) {
      noisePlayer.playWhiteNoise();
    }
    final logTemplate = '                 |' * 11;
    String log = logTemplate;
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      print(DateFormat.Hms().format(DateTime.now()) + log);
      log = logTemplate;
    });
    Timer.periodic(const Duration(milliseconds: 100), (_) {
      noiseLevels.forEach((id, level) {
        if (_canPlay(level)) {
          noisePlayer.playNoise(id);
          log = log.replaceRange(id * 18 + 7, id * 18 + 10, '***');
        }
      });
    });
  }

  bool _canPlay(int level) {
    return level * probabilityMultiple > _random.nextDouble();
  }
}
