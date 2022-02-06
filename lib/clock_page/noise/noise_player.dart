import 'package:just_audio/just_audio.dart';

abstract class NoisePlayer {
  void playWhiteNoise();

  void playNoise(int noiseId);

  void dispose();
}

const _noiseAssetPath = 'assets/noises';

class NoiseAudioPlayer implements NoisePlayer {
  AudioPlayer? whiteNoisePlayer;

  @override
  void playNoise(int noiseId) {}

  @override
  void playWhiteNoise() async {
    whiteNoisePlayer ??= AudioPlayer();
    await whiteNoisePlayer?.setAudioSource(
      ConcatenatingAudioSource(
        children: [
          AudioSource.uri(Uri.parse('asset:///$_noiseAssetPath/white_noise.mp3')),
          AudioSource.uri(Uri.parse('asset:///$_noiseAssetPath/white_noise.mp3')),
        ],
      ),
    );
    await whiteNoisePlayer?.setLoopMode(LoopMode.all);
    await whiteNoisePlayer?.play();
  }

  @override
  void dispose() async {
    await whiteNoisePlayer?.dispose();
  }
}
