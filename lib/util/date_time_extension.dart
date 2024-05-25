import 'package:flutter/material.dart';

extension DateTimeBuilder on DateTime {
  static DateTime fromHourMinute(int hour, int minute) =>
      DateTime(0, 1, 1, hour, minute);
}

extension DateTimeUtil on DateTime {
  DateTime toDate() {
    return DateTime(year, month, day);
  }

  bool isSameOrAfter(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }
}

extension DurationExtension on Duration {
  String to2DigitString() {
    final minutes = inMinutes.toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

extension TimeOfDayExtension on TimeOfDay {
  DateTime toDateTime() {
    return DateTime(0, 1, 1, hour, minute);
  }
}
