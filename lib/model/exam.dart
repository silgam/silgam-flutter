import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../presentation/app/cubit/app_cubit.dart';
import '../util/date_time_extension.dart';
import '../util/injection.dart';
import 'announcement.dart';
import 'relative_time.dart';
import 'subject.dart';

part 'exam.freezed.dart';
part 'exam.g.dart';

@freezed
class Exam with _$Exam {
  Exam._();

  factory Exam({
    required String id,
    String? userId,
    required Subject subject,
    required String name,
    required int number,
    @JsonKey(fromJson: timeFromJson, toJson: timeToJson) required DateTime startTime,
    required int durationMinutes,
    required int numberOfQuestions,
    required int perfectScore,
    @Default(true) bool isBeforeFinishAnnouncementEnabled,
    @Default(true) bool isListeningEndAnnouncementEnabled,
    required int color,
    DateTime? createdAt,
  }) = _Exam;

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);

  factory Exam.fromId(String id) {
    final AppState appState = getIt.get<AppCubit>().state;
    return appState.getAllExams().firstWhereOrNull((element) => element.id == id) ??
        appState.getDefaultExams().first.copyWith(id: id, name: '알 수 없는 과목');
  }

  static String toId(Exam exam) => exam.id;

  late final DateTime endTime = startTime.add(Duration(minutes: durationMinutes));

  late final DateTime timetableStartTime = startTime.subtract(
    Duration(minutes: subject.minutesBeforeExamStart),
  );

  int get timetableDurationMinutes =>
      durationMinutes + subject.minutesBeforeExamStart + subject.minutesAfterExamFinish;

  bool get isCustomExam => userId != null;

  late final List<Announcement> announcements =
      subject.defaultAnnouncements.where((announcement) {
        final isOverExamDuration =
            (announcement.time.type == RelativeTimeType.afterStart ||
                announcement.time.type == RelativeTimeType.beforeFinish) &&
            announcement.time.minutes >= durationMinutes;
        final skipBeforeFinishAnnouncement =
            !isBeforeFinishAnnouncementEnabled &&
            announcement.purpose == AnnouncementPurpose.beforeFinish;
        final skipListeningEndAnnouncement =
            !isListeningEndAnnouncementEnabled &&
            announcement.purpose == AnnouncementPurpose.listeningEnd;

        return !isOverExamDuration &&
            !skipBeforeFinishAnnouncement &&
            !skipListeningEndAnnouncement;
      }).toList();

  late final Announcement? firstAnnouncement = announcements.firstOrNull;

  late final Announcement? startAnnouncement = announcements.firstWhereOrNull(
    (announcement) => announcement.purpose == AnnouncementPurpose.start,
  );

  late final Announcement? finishAnnouncement = announcements.lastWhereOrNull(
    (announcement) => announcement.purpose == AnnouncementPurpose.finish,
  );
}

DateTime timeFromJson(String json) {
  final parts = json.split(':');
  return DateTimeBuilder.fromHourMinute(int.parse(parts[0]), int.parse(parts[1]));
}

String timeToJson(DateTime dateTime) {
  return '${dateTime.hour}:${dateTime.minute}';
}
