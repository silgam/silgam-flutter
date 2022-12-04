import 'package:just_audio/just_audio.dart';

import '../breakpoint.dart';

class ListeningAudioPlayer {
  final List<Breakpoint> breakpoints;
  final AudioSource audioSource;
  final Duration examStartPosition;
  late final Breakpoint _examStartBreakpoint;
  final AudioPlayer _audioPlayer = AudioPlayer();

  ListeningAudioPlayer({
    required this.breakpoints,
    required this.audioSource,
    required this.examStartPosition,
  }) {
    _init();
  }

  void updateState(DateTime currentTime, {required bool timeJumped}) {
    DateTime audioStartTime =
        _examStartBreakpoint.time.subtract(examStartPosition);
    if (currentTime.compareTo(audioStartTime) >= 0) {}
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  void _init() async {
    _examStartBreakpoint =
        breakpoints.firstWhere((e) => e.title.contains('본령'));
    await _audioPlayer.setAudioSource(audioSource);
  }
}
