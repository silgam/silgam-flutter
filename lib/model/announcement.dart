import 'relative_time.dart';

class Announcement {
  final String title;
  final RelativeTime time;

  const Announcement({
    required this.time,
    required this.title,
  });
}
