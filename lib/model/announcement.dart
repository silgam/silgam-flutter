import 'relative_time.dart';

class Announcement {
  final String title;
  final RelativeTime time;
  final String? fileName;

  const Announcement({
    required this.time,
    required this.title,
    this.fileName,
  });
}
