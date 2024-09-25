import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../presentation/app/cubit/app_cubit.dart';
import '../util/date_time_extension.dart';
import '../util/injection.dart';
import 'subject.dart';

part 'exam.freezed.dart';
part 'exam.g.dart';

@freezed
class Exam with _$Exam {
  const Exam._();

  factory Exam({
    required String id,
    String? userId,
    required Subject subject,
    required String name,
    required int number,
    @JsonKey(fromJson: timeFromJson, toJson: timeToJson)
    required DateTime startTime,
    required int durationMinutes,
    required int numberOfQuestions,
    required int perfectScore,
    @Default(true) bool isBeforeFinishAnnouncementEnabled,
    required int color,
    DateTime? createdAt,
  }) = _Exam;

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);

  factory Exam.fromId(String id) {
    final AppState appState = getIt.get<AppCubit>().state;
    return appState
            .getAllExams()
            .firstWhereOrNull((element) => element.id == id) ??
        appState.getDefaultExams().first.copyWith(id: id, name: '알 수 없는 과목');
  }

  static String toId(Exam exam) => exam.id;

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  DateTime get timetableStartTime =>
      startTime.subtract(Duration(minutes: subject.minutesBeforeExamStart));

  int get timetableDurationMinutes =>
      durationMinutes +
      subject.minutesBeforeExamStart +
      subject.minutesAfterExamFinish;

  bool get isCustomExam => userId != null;
}

DateTime timeFromJson(String json) {
  final parts = json.split(':');
  return DateTimeBuilder.fromHourMinute(
      int.parse(parts[0]), int.parse(parts[1]));
}

String timeToJson(DateTime dateTime) {
  return '${dateTime.hour}:${dateTime.minute}';
}
