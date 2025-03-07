import 'package:freezed_annotation/freezed_annotation.dart';

import 'relative_time.dart';

part 'announcement.freezed.dart';

@freezed
class Announcement with _$Announcement {
  const factory Announcement({
    required String title,
    required RelativeTime time,
    required AnnouncementPurpose purpose,
    String? fileName,
  }) = _Announcement;
}

enum AnnouncementPurpose { preliminary, prepare, start, beforeFinish, finish, other }
