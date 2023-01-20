import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_failure.freezed.dart';
part 'api_failure.g.dart';

@freezed
class ApiFailure with _$ApiFailure implements Exception {
  const factory ApiFailure(String message) = _ApiFailure;

  factory ApiFailure.from(FailureBody failureBody) =>
      ApiFailure(failureBody.message);
}

@freezed
class FailureBody with _$FailureBody {
  const factory FailureBody({
    required String message,
  }) = _FailureBody;

  factory FailureBody.unknown() =>
      const FailureBody(message: '알 수 없는 오류가 발생했습니다.');

  factory FailureBody.unauthorized() =>
      const FailureBody(message: '인증에 실패했습니다. 다시 로그인해주세요.');

  factory FailureBody.fromJson(Map<String, dynamic> json) =>
      _$FailureBodyFromJson(json);
}
