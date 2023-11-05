import 'dart:math';

import 'package:just_audio/just_audio.dart';

import '../../../repository/noise_repository.dart';

abstract class NoisePlayer {
  void playWhiteNoise();

  void pauseWhiteNoise();

  Future<void> playNoise({required int noiseId, int delayMillis = 0});

  void dispose();
}

class NoiseAudioPlayer implements NoisePlayer {
  NoiseAudioPlayer({required this.availableNoiseIds});

  final List<int> availableNoiseIds;
  final AudioPlayer _whiteNoisePlayer = AudioPlayer();
  final Map<int, AudioPlayer> _noisePlayers = {};

  @override
  Future<void> playNoise({required int noiseId, int delayMillis = 0}) async {
    if (!availableNoiseIds.contains(noiseId)) return;
    Noise noise = Noise.byId(noiseId);
    String? noisePath = noise.getRandomNoisePath();
    if (noisePath == null) return;

    int playerId = DateTime.now().millisecondsSinceEpoch;
    _noisePlayers[playerId] = AudioPlayer();
    final AudioPlayer audioPlayer = _noisePlayers[playerId]!;

    await audioPlayer.setAsset(noisePath);
    double volume = (Random().nextDouble() + 2) * 2;
    await audioPlayer.setVolume(volume);
    await Future.delayed(Duration(milliseconds: delayMillis));

    await audioPlayer.play();
    await audioPlayer.stop();
    await audioPlayer.dispose();
    _noisePlayers.remove(playerId);
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
    await _whiteNoisePlayer.stop();
    await _whiteNoisePlayer.dispose();
    await Future.wait(_noisePlayers.values.map((player) async {
      await player.stop();
      await player.dispose();
    }));
  }
}
