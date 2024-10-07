extension DurationExtension on Duration {
  String toKoreanString() {
    final hours = inHours;
    final minutes = inMinutes % 60;
    if (hours == 0) {
      return '$minutes분';
    } else {
      return '$hours시간 $minutes분';
    }
  }

  /// 실제로는 60분이지만 미세한 차이로 59분 59초인 경우가 있기 때문에 1초를 더해서 이를 방지
  ///
  /// [관련 슬랙 메시지](https://silgam.slack.com/archives/C038LL94EUR/p1728268361059709?thread_ts=1727766981.046459&cid=C038LL94EUR)
  int get inMinutesWithCorrection =>
      (this + const Duration(seconds: 1)).inMinutes;
}
