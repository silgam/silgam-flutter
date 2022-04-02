import 'package:just_audio/just_audio.dart';

import '../../repository/noise_repository.dart';

abstract class NoisePlayer {
  void playWhiteNoise();

  void playNoise(int noiseId);

  void dispose();
}

class NoiseAudioPlayer implements NoisePlayer {
  AudioPlayer? whiteNoisePlayer;

  @override
  void playNoise(int noiseId) {}

  @override
  void playWhiteNoise() async {
    whiteNoisePlayer ??= AudioPlayer();
    await whiteNoisePlayer?.setAsset(whiteNoisePath);
    await whiteNoisePlayer?.setLoopMode(LoopMode.all);
    await whiteNoisePlayer?.play();
  }

  @override
  void dispose() async {
    await whiteNoisePlayer?.dispose();
  }
}
