import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:just_audio/just_audio.dart';

import '../../../repository/noise/noise_repository.dart';

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
  final Map<String, Queue<AudioPlayer>> _noisePathToPlayers = {};

  @override
  Future<void> playNoise({required int noiseId, int delayMillis = 0}) async {
    if (!availableNoiseIds.contains(noiseId)) return;

    if (delayMillis > 0) {
      await Future.delayed(Duration(milliseconds: delayMillis));
    }

    String noisePath = Noise.byId(noiseId).getRandomNoisePath();
    await _playNoise(noisePath);
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
    await Future.wait(_noisePathToPlayers.values.flattened.map((player) async {
      await player.stop();
      await player.dispose();
    }));
  }

  Future<void> _playNoise(String noisePath) async {
    _noisePathToPlayers[noisePath] ??= Queue();
    final Queue<AudioPlayer> playersQueue = _noisePathToPlayers[noisePath]!;

    final AudioPlayer player =
        playersQueue.getIdlePlayer() ?? await _createNewPlayer(noisePath);

    double volume = (Random().nextDouble() + 2) * 2;
    await player.setVolume(volume);

    if (player.position == Duration.zero) {
      player.play();
    } else {
      player.seek(Duration.zero);
    }

    playersQueue.addLast(player);
  }

  Future<AudioPlayer> _createNewPlayer(String noisePath) async {
    return AudioPlayer()..setAsset(noisePath);
  }
}

extension on Queue<AudioPlayer> {
  bool get hasIdlePlayer =>
      isNotEmpty && first.processingState == ProcessingState.completed;

  AudioPlayer? getIdlePlayer() => hasIdlePlayer ? removeFirst() : null;
}
