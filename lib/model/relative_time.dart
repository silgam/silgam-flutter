class RelativeTime {
  final RelativeTimeType type;
  final int minutes;

  const RelativeTime.beforeStart({
    required this.minutes,
  }) : type = RelativeTimeType.beforeStart;

  const RelativeTime.afterStart({
    required this.minutes,
  }) : type = RelativeTimeType.afterStart;

  const RelativeTime.beforeFinish({
    required this.minutes,
  }) : type = RelativeTimeType.beforeFinish;

  const RelativeTime.afterFinish({
    required this.minutes,
  }) : type = RelativeTimeType.afterFinish;
}

enum RelativeTimeType { beforeStart, afterStart, beforeFinish, afterFinish }
