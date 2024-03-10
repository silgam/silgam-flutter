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
}
