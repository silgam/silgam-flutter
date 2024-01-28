import '../../model/lap_time.dart';

List<LapTimeItemGroup> getExampleLapTimeGroups({
  required DateTime startTime,
}) =>
    [
      LapTimeItemGroup(
        title: '예비령',
        startTime: startTime,
        lapTimeItems: [
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 1, seconds: 15)),
            timeDifference: const Duration(minutes: 1, seconds: 15),
            timeElapsed: const Duration(minutes: 1, seconds: 15),
          ),
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 7, seconds: 33)),
            timeDifference: const Duration(minutes: 6, seconds: 18),
            timeElapsed: const Duration(minutes: 7, seconds: 33),
          ),
        ],
      ),
      LapTimeItemGroup(
        title: '본령',
        startTime: startTime.add(const Duration(minutes: 10)),
        lapTimeItems: [
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 12, seconds: 5)),
            timeDifference: const Duration(minutes: 2, seconds: 5),
            timeElapsed: const Duration(minutes: 2, seconds: 5),
          ),
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 18, seconds: 12)),
            timeDifference: const Duration(minutes: 6, seconds: 7),
            timeElapsed: const Duration(minutes: 8, seconds: 12),
          ),
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 20, seconds: 44)),
            timeDifference: const Duration(minutes: 2, seconds: 32),
            timeElapsed: const Duration(minutes: 10, seconds: 44),
          ),
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 25, seconds: 17)),
            timeDifference: const Duration(minutes: 4, seconds: 33),
            timeElapsed: const Duration(minutes: 15, seconds: 17),
          ),
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 26, seconds: 48)),
            timeDifference: const Duration(minutes: 1, seconds: 31),
            timeElapsed: const Duration(minutes: 16, seconds: 48),
          ),
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 29, seconds: 51)),
            timeDifference: const Duration(minutes: 3, seconds: 3),
            timeElapsed: const Duration(minutes: 19, seconds: 51),
          ),
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 41, seconds: 27)),
            timeDifference: const Duration(minutes: 11, seconds: 36),
            timeElapsed: const Duration(minutes: 31, seconds: 27),
          ),
          LapTimeItem(
            time: startTime.add(const Duration(minutes: 56, seconds: 4)),
            timeDifference: const Duration(minutes: 14, seconds: 37),
            timeElapsed: const Duration(minutes: 46, seconds: 4),
          ),
        ],
      ),
    ];
