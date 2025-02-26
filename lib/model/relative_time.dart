class RelativeTime {
  final RelativeTimeType type;
  final int minutes;

  const RelativeTime.beforeStart({required this.minutes})
    : type = RelativeTimeType.beforeStart;

  const RelativeTime.afterStart({required this.minutes})
    : type = RelativeTimeType.afterStart;

  const RelativeTime.beforeFinish({required this.minutes})
    : type = RelativeTimeType.beforeFinish;

  const RelativeTime.afterFinish({required this.minutes})
    : type = RelativeTimeType.afterFinish;

  DateTime calculateBreakpointTime(
    DateTime examStartTime,
    DateTime examEndTime,
  ) {
    switch (type) {
      case RelativeTimeType.beforeStart:
        return examStartTime.subtract(Duration(minutes: minutes));
      case RelativeTimeType.afterStart:
        return examStartTime.add(Duration(minutes: minutes));
      case RelativeTimeType.beforeFinish:
        return examEndTime.subtract(Duration(minutes: minutes));
      case RelativeTimeType.afterFinish:
        return examEndTime.add(Duration(minutes: minutes));
    }
  }
}

enum RelativeTimeType { beforeStart, afterStart, beforeFinish, afterFinish }
