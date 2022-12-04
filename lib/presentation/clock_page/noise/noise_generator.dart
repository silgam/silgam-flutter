import 'dart:async';
import 'dart:math';

import 'package:silgam/model/subject.dart';

import '../../../model/exam.dart';
import '../../../model/relative_time.dart';
import '../../../repository/noise_repository.dart';
import '../breakpoint.dart';
import 'noise_player.dart';

class NoiseGenerator {
  static const double _probabilityMultiple = 0.001;
  final NoiseSettings noiseSettings;
  final NoisePlayer noisePlayer;
  final ClockStatus Function() fetchClockStatus;
  final _random = Random();
  Timer? _timer;

  NoiseGenerator({
    required this.noiseSettings,
    required this.noisePlayer,
    required this.fetchClockStatus,
  });

  void start() {
    playWhiteNoiseIfEnabled();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      ClockStatus clockStatus = fetchClockStatus();
      if (!clockStatus.isRunning) return;
      RelativeTimeType currentRelativeTime =
          clockStatus.currentBreakpoint.announcement.time.type;
      noiseSettings.noiseLevels.forEach((id, level) {
        double levelMultiple = 1;
        int delay = 0;
        // 시험지 넘기는 소리 예외 사항
        if (id == 0) {
          if (currentRelativeTime == RelativeTimeType.beforeStart) {
            levelMultiple = 0; // 시험 시작 전엔 시험지 안 넘김
          } else if (currentRelativeTime == RelativeTimeType.afterStart) {
            int afterStart = clockStatus.currentTime
                .difference(clockStatus.currentBreakpoint.time)
                .inSeconds;
            if (afterStart <= 2) {
              delay = 1000;
              levelMultiple = 50; // 시험 시작 직후 시험지 많이 넘김
            } else if (2 < afterStart && afterStart <= 7) {
              delay = 1000;
              levelMultiple = 10; // 시험 시작 후 일정 시간 동안 시험지 조금 넘김
            }
          } else if (currentRelativeTime == RelativeTimeType.beforeFinish) {
            int beforeFinish = clockStatus.currentTime
                .difference(clockStatus.currentBreakpoint.time)
                .inMinutes;
            if (clockStatus.exam.subject == Subject.investigation ||
                clockStatus.exam.subject == Subject.investigation2) {
              beforeFinish = 5 - beforeFinish;
            } else {
              beforeFinish = 10 - beforeFinish;
            }
            if (beforeFinish <= 2) {
              levelMultiple = 10; // 시험 종료 직전 시험지 많이 넘김
            } else if (2 < beforeFinish && beforeFinish <= 10) {
              levelMultiple = 2; // 시험 종료 전 일정 시간 동안 시험지 조금 넘김
            }
          }
        }
        if (_calculateProbability(level * levelMultiple)) {
          noisePlayer.playNoise(noiseId: id, delayMillis: delay);
        }
      });
    });
  }

  void playWhiteNoiseIfEnabled() {
    if (noiseSettings.useWhiteNoise) {
      noisePlayer.playWhiteNoise();
    }
  }

  void pauseWhiteNoise() {
    noisePlayer.pauseWhiteNoise();
  }

  void dispose() {
    _timer?.cancel();
    noisePlayer.dispose();
  }

  bool _calculateProbability(double level) {
    return level * _probabilityMultiple > _random.nextDouble();
  }
}

class ClockStatus {
  final Exam exam;
  final Breakpoint currentBreakpoint;
  final DateTime currentTime;
  final bool isRunning;

  const ClockStatus({
    required this.exam,
    required this.currentBreakpoint,
    required this.currentTime,
    required this.isRunning,
  });
}
