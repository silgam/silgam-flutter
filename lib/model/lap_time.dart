import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../util/date_time_extension.dart';

part 'lap_time.freezed.dart';

@freezed
class LapTime with _$LapTime {
  const factory LapTime({
    required DateTime time,
    required DateTime createdAt,
  }) = _LapTime;
}

@freezed
class LapTimeItem with _$LapTimeItem {
  const factory LapTimeItem({
    required DateTime time,
    required Duration timeDifference,
    required Duration timeElapsed,
  }) = _LapTimeItem;
}

@freezed
class LapTimeItemGroup with _$LapTimeItemGroup {
  const factory LapTimeItemGroup({
    required String title,
    required DateTime startTime,
    required List<LapTimeItem> lapTimeItems,
  }) = _LapTimeItemGroup;
}

extension LapTimeItemGroupsExtension on List<LapTimeItemGroup> {
  String toCopyableString() {
    final buffer = StringBuffer();
    buffer.writeln('      |      시간      |   간격   |   누적   |  분류');

    for (final group in this) {
      buffer.writeln(
        '————————————————————',
      );
      buffer.writeln(
        '  0 | ${DateFormat.Hms().format(group.startTime)} | 00:00 | 00:00 | ${group.title}',
      );

      group.lapTimeItems.forEachIndexed((index, item) {
        buffer.writeln(
            '${index >= 9 ? '' : '  '}${index + 1} | ${DateFormat.Hms().format(item.time)} | ${item.timeDifference.to2DigitString()} | ${item.timeElapsed.to2DigitString()} | ');
      });
    }
    return buffer.toString();
  }

  bool get isItemsEmpty {
    return every((group) => group.lapTimeItems.isEmpty);
  }
}
