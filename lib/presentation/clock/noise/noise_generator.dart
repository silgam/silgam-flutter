import 'dart:async';
import 'dart:math';

import '../../../model/announcement.dart';
import '../../../repository/noise/noise_repository.dart';
import '../breakpoint.dart';
import '../cubit/clock_cubit.dart';
import 'noise_player.dart';

class NoiseGenerator {
  NoiseGenerator({
    required this.noisePlayer,
    required this.getClockState,
    required this.useWhiteNoise,
    required this.noiseLevels,
  });

  final NoisePlayer noisePlayer;
  final ClockState Function() getClockState;
  final bool useWhiteNoise;
  final Map<int, int> noiseLevels;

  static const double _probabilityMultiple = 0.001;

  Timer? _timer;

  void start() {
    playWhiteNoiseIfEnabled();

    _timer = Timer.periodic(const Duration(milliseconds: 100), _onEveryTick);
  }

  void _onEveryTick(Timer timer) async {
    ClockState clockState = getClockState();
    if (!clockState.isRunning) return;

    for (final MapEntry(key: id, value: level) in noiseLevels.entries) {
      final levelMultiple = _calculateLevelMultiple(
        noiseId: id,
        currentBreakpoint: clockState.currentBreakpoint,
        currentTime: clockState.currentTime,
      );

      if (_shouldPlayNoise(level * levelMultiple)) {
        await noisePlayer.playNoise(id);
      }
    }
  }

  void playWhiteNoiseIfEnabled() {
    if (useWhiteNoise) {
      noisePlayer.playWhiteNoise();
    }
  }

  void pauseWhiteNoise() {
    noisePlayer.pauseWhiteNoise();
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await noisePlayer.dispose();
  }

  /// 소음 예외사항을 고려하여 각 소음에 대해 현재 시점에 얼마나 자주 소리가 나야 하는지 계산함
  double _calculateLevelMultiple({
    required int noiseId,
    required Breakpoint currentBreakpoint,
    required DateTime currentTime,
  }) {
    final secondsSinceBreakpoint = currentTime.difference(currentBreakpoint.time).inSeconds;

    switch (currentBreakpoint.announcement.purpose) {
      case AnnouncementPurpose.preliminary:
        switch (noiseId) {
          case NoiseId.clothes:
          case NoiseId.chairMoving:
          case NoiseId.chairCreaking:
            return 1.5;
          case NoiseId.erasing:
          case NoiseId.sharpClicking:
          case NoiseId.paperFlipping:
            return 0;
          case NoiseId.writing:
            if (10 <= secondsSinceBreakpoint && secondsSinceBreakpoint <= 50) {
              return 3;
            }
            return 0;
          default:
            return 1;
        }

      case AnnouncementPurpose.prepare:
        switch (noiseId) {
          case NoiseId.paperFlipping:
            if (secondsSinceBreakpoint < 20) {
              return 0;
            } else if (secondsSinceBreakpoint <= 30) {
              return 5;
            } else if (secondsSinceBreakpoint <= 50) {
              return 10;
            } else if (secondsSinceBreakpoint <= 60) {
              return 5;
            } else if (secondsSinceBreakpoint <= 80) {
              return 2;
            }
            return 0;
          case NoiseId.erasing:
          case NoiseId.sharpClicking:
            return 0;
          case NoiseId.writing:
            if (20 <= secondsSinceBreakpoint && secondsSinceBreakpoint <= 40) {
              return 3;
            }
            return 0;
          default:
            return 1;
        }

      case AnnouncementPurpose.changePaper:
        switch (noiseId) {
          case NoiseId.sharpClicking:
          case NoiseId.writing:
          case NoiseId.erasing:
            return 0;
          case NoiseId.chairMoving:
          case NoiseId.chairCreaking:
          case NoiseId.clothes:
            if (5 <= secondsSinceBreakpoint && secondsSinceBreakpoint <= 15) {
              return 3;
            }
            return 1;
          case NoiseId.paperFlipping:
            if (5 <= secondsSinceBreakpoint && secondsSinceBreakpoint <= 30) {
              return 5;
            }
            return 0;
          default:
            return 1;
        }

      case AnnouncementPurpose.start:
        switch (noiseId) {
          case NoiseId.paperFlipping:
            if (secondsSinceBreakpoint < 1) {
              return 0;
            } else if (secondsSinceBreakpoint <= 3) {
              return 50;
            } else if (secondsSinceBreakpoint <= 8) {
              return 10;
            }
            return 1;
          default:
            return 1;
        }

      case AnnouncementPurpose.listeningEnd:
        switch (noiseId) {
          case NoiseId.paperFlipping:
            if (secondsSinceBreakpoint <= 2) {
              return 30;
            } else if (secondsSinceBreakpoint <= 9) {
              return 10;
            }
            return 1;
          case NoiseId.manCough:
          case NoiseId.womanCough:
            if (secondsSinceBreakpoint <= 10) {
              return 5;
            }
            return 1;
          default:
            return 1;
        }

      case AnnouncementPurpose.beforeFinish:
        int totalSecondsBeforeFinish = currentBreakpoint.announcement.time.minutes * 60;
        int secondsRemaining = totalSecondsBeforeFinish - secondsSinceBreakpoint;

        switch (noiseId) {
          case NoiseId.paperFlipping:
          case NoiseId.writing:
            if (secondsRemaining <= 2 * 60) {
              return 10;
            }
            return 3;
          case NoiseId.erasing:
          case NoiseId.sharpClicking:
            return 3;
          default:
            return 1;
        }

      case AnnouncementPurpose.finish:
        switch (noiseId) {
          case NoiseId.sigh:
            if (secondsSinceBreakpoint <= 5) {
              return 12;
            } else if (secondsSinceBreakpoint <= 20) {
              return 8;
            }
            return 1;
          case NoiseId.paperFlipping:
          case NoiseId.writing:
          case NoiseId.sharpClicking:
          case NoiseId.erasing:
            return 0;
          default:
            return 1;
        }
    }
  }

  bool _shouldPlayNoise(double level) {
    return level * _probabilityMultiple > Random().nextDouble();
  }
}
