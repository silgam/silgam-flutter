import 'dart:async';
import 'dart:math';

import '../../../model/relative_time.dart';
import '../../../model/subject.dart';
import '../../noise_setting/cubit/noise_setting_cubit.dart';
import '../cubit/clock_cubit.dart';
import 'noise_player.dart';

class NoiseGenerator {
  static const double _probabilityMultiple = 0.001;
  final NoiseSettingState noiseSettingState;
  final NoisePlayer noisePlayer;
  final ClockCubit clockCubit;
  final _random = Random();
  Timer? _timer;

  NoiseGenerator({
    required this.noiseSettingState,
    required this.noisePlayer,
    required this.clockCubit,
  });

  void start() {
    playWhiteNoiseIfEnabled();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      ClockState clockState = clockCubit.state;
      if (!clockState.isRunning) return;
      RelativeTimeType currentRelativeTime = clockState.currentBreakpoint.announcement.time.type;
      for (final MapEntry(key: id, value: level) in noiseSettingState.noiseLevels.entries) {
        double levelMultiple = 1;
        int delay = 0;
        // 시험지 넘기는 소리 예외 사항
        if (id == 0) {
          if (currentRelativeTime == RelativeTimeType.beforeStart) {
            levelMultiple = 0; // 시험 시작 전엔 시험지 안 넘김
          } else if (currentRelativeTime == RelativeTimeType.afterStart) {
            int afterStart =
                clockState.currentTime.difference(clockState.currentBreakpoint.time).inSeconds;
            if (afterStart <= 2) {
              delay = 1000;
              levelMultiple = 50; // 시험 시작 직후 시험지 많이 넘김
            } else if (2 < afterStart && afterStart <= 7) {
              delay = 1000;
              levelMultiple = 10; // 시험 시작 후 일정 시간 동안 시험지 조금 넘김
            }
          } else if (currentRelativeTime == RelativeTimeType.beforeFinish) {
            int beforeFinish =
                clockState.currentTime.difference(clockState.currentBreakpoint.time).inMinutes;
            if (clockState.currentExam.subject == Subject.investigation ||
                clockState.currentExam.subject == Subject.investigation2) {
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
          await noisePlayer.playNoise(noiseId: id, delayMillis: delay);
        }
      }
    });
  }

  void playWhiteNoiseIfEnabled() {
    if (noiseSettingState.useWhiteNoise) {
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

  bool _calculateProbability(double level) {
    return level * _probabilityMultiple > _random.nextDouble();
  }
}
