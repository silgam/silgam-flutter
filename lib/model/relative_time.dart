class RelativeTime {
  final RelativeTimeType type;
  final int minutes;

  RelativeTime.beforeStart({
    required this.minutes,
  }) : type = RelativeTimeType.beforeStart;

  RelativeTime.afterStart({
    required this.minutes,
  }) : type = RelativeTimeType.afterStart;

  RelativeTime.afterFinish({
    required this.minutes,
  }) : type = RelativeTimeType.afterFinish;
}

enum RelativeTimeType { beforeStart, afterStart, afterFinish }
