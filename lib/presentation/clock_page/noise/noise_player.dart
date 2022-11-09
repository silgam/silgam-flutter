import 'dart:math';

import 'package:just_audio/just_audio.dart';

import '../../../repository/noise_repository.dart';

abstract class NoisePlayer {
  void playWhiteNoise();

  void pauseWhiteNoise();

  void playNoise({required int noiseId, int delayMillis = 0});

  void dispose();
}

class NoiseAudioPlayer implements NoisePlayer {
  final AudioPlayer _whiteNoisePlayer = AudioPlayer();
  final Map<int, AudioPlayer> _noisePlayers = {};

  @override
  void playNoise({required int noiseId, int delayMillis = 0}) async {
    Noise noise = Noise.byId(noiseId);
    String? noisePath = noise.getRandomNoisePath();
    if (noisePath == null) return;

    final audioPlayer = AudioPlayer();
    int playerId = DateTime.now().millisecondsSinceEpoch;
    _noisePlayers[playerId] = audioPlayer;

    await audioPlayer.setAsset(noisePath);
    double volume = (Random().nextDouble() + 2) * 2;
    await audioPlayer.setVolume(volume);
    await Future.delayed(Duration(milliseconds: delayMillis));

    await audioPlayer.play();
    _noisePlayers.remove(playerId);
    await audioPlayer.dispose();
  }

  @override
  void playWhiteNoise() async {
    await _whiteNoisePlayer.setAsset(whiteNoisePath);
    await _whiteNoisePlayer.setLoopMode(LoopMode.all);
    await _whiteNoisePlayer.setVolume(2);
    await _whiteNoisePlayer.play();
  }

  @override
  void pauseWhiteNoise() async {
    await _whiteNoisePlayer.pause();
  }

  @override
  void dispose() async {
    await _whiteNoisePlayer.dispose();
    await Future.wait(_noisePlayers.values.map((player) => player.dispose()));
  }
}
