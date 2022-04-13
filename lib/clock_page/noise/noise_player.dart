import 'dart:math';

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
  void playNoise(int noiseId) async {
    Noise noise = Noise.byId(noiseId);
    String? noisePath = noise.getRandomNoisePath();
    if (noisePath == null) return;
    final audioPlayer = AudioPlayer();
    await audioPlayer.setAsset(noisePath);
    double volume = Random().nextDouble();
    await audioPlayer.setVolume(volume);
    await audioPlayer.play();
    await audioPlayer.dispose();
  }

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
