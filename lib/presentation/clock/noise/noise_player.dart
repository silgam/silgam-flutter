import 'dart:math';

import 'package:just_audio/just_audio.dart';

import '../../../repository/noise/noise_repository.dart';

abstract class NoisePlayer {
  void playWhiteNoise();

  void pauseWhiteNoise();

  Future<void> playNoise(int noiseId);

  Future<void> dispose();
}

class NoiseAudioPlayer implements NoisePlayer {
  final AudioPlayer _whiteNoisePlayer = AudioPlayer();
  final Map<int, AudioPlayer> _undisposedNoisePlayers = {};

  bool _isDisposed = false;

  @override
  Future<void> playNoise(int noiseId) async {
    if (_isDisposed) return;

    Noise noise = Noise.byId(noiseId);
    String noisePath = noise.getRandomNoisePath();

    int playerId = DateTime.now().millisecondsSinceEpoch;
    _undisposedNoisePlayers[playerId] = AudioPlayer();
    final AudioPlayer audioPlayer = _undisposedNoisePlayers[playerId]!;

    await audioPlayer.setAsset(noisePath);
    double volume = (Random().nextDouble() + 2) * 2;
    await audioPlayer.setVolume(volume);

    await audioPlayer.play();

    await _disposeNoisePlayer(playerId);
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
  Future<void> dispose() async {
    _isDisposed = true;

    await _whiteNoisePlayer.stop();
    await _whiteNoisePlayer.dispose();

    await Future.wait([..._undisposedNoisePlayers.keys].map(_disposeNoisePlayer));
  }

  Future<void> _disposeNoisePlayer(int playerId) async {
    final undisposedNoisePlayer = _undisposedNoisePlayers.remove(playerId);
    await undisposedNoisePlayer?.stop();
    await undisposedNoisePlayer?.dispose();
  }
}
