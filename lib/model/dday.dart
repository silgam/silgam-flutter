import 'package:freezed_annotation/freezed_annotation.dart';

part 'dday.freezed.dart';
part 'dday.g.dart';

@freezed
class DDay with _$DDay {
  const factory DDay({required DDayType testType, required String title, required DateTime date}) =
      _DDay;

  factory DDay.fromJson(Map<String, dynamic> json) => _$DDayFromJson(json);
}

enum DDayType { suneung, mockTest }
