extension DateTimeBuilder on DateTime {
  static DateTime fromHourMinute(int hour, int minute) =>
      DateTime(0, 1, 1, hour, minute);
}

extension DateTimeUtil on DateTime {
  int get hour12 {
    if (hour > 12) {
      return hour - 12;
    } else {
      return hour;
    }
  }
}
