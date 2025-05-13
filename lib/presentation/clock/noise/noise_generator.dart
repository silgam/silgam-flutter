import 'dart:async';
import 'dart:math';

import '../../../model/exam.dart';
import '../../../model/relative_time.dart';
import '../../../model/subject.dart';
import '../../../repository/noise/noise_repository.dart';
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
        currentRelativeTime: clockState.currentBreakpoint.announcement.time.type,
        currentTime: clockState.currentTime,
        currentBreakpointTime: clockState.currentBreakpoint.time,
        currentExam: clockState.currentExam,
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

  double _calculateLevelMultiple({
    required int noiseId,
    required RelativeTimeType currentRelativeTime,
    required DateTime currentTime,
    required DateTime currentBreakpointTime,
    required Exam currentExam,
  }) {
    double levelMultiple = 1;

    // 시험지 넘기는 소리 예외 사항
    if (noiseId == NoiseId.paperFlipping) {
      if (currentRelativeTime == RelativeTimeType.beforeStart) {
        levelMultiple = 0; // 시험 시작 전엔 시험지 안 넘김
      } else if (currentRelativeTime == RelativeTimeType.afterStart) {
        int afterStart = currentTime.difference(currentBreakpointTime).inSeconds;
        if (1 <= afterStart && afterStart <= 3) {
          levelMultiple = 50; // 시험 시작 직후 시험지 많이 넘김
        } else if (3 < afterStart && afterStart <= 8) {
          levelMultiple = 10; // 시험 시작 후 일정 시간 동안 시험지 조금 넘김
        }
      } else if (currentRelativeTime == RelativeTimeType.beforeFinish) {
        int beforeFinish = currentTime.difference(currentBreakpointTime).inMinutes;
        if (currentExam.subject == Subject.investigation ||
            currentExam.subject == Subject.investigation2) {
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

    return levelMultiple;
  }

  bool _shouldPlayNoise(double level) {
    return level * _probabilityMultiple > Random().nextDouble();
  }
}
