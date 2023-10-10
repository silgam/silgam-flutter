import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_failure.freezed.dart';

@freezed
class ApiFailure with _$ApiFailure implements Exception {
  const factory ApiFailure({
    required ApiFailureType type,
    required String message,
  }) = _ApiFailure;

  factory ApiFailure.from(ApiFailureType type) =>
      ApiFailure(type: type, message: type.message);

  factory ApiFailure.unknown() => ApiFailure.from(ApiFailureType.unknown);
  factory ApiFailure.unauthorized() =>
      ApiFailure.from(ApiFailureType.unauthorized);
  factory ApiFailure.noNetwork() => ApiFailure.from(ApiFailureType.noNetwork);
}

enum ApiFailureType {
  unknown(message: '알 수 없는 오류가 발생했습니다.'),
  unauthorized(message: '인증에 실패했습니다. 다시 로그인해주세요.'),
  noNetwork(message: '인터넷 연결을 확인해주세요.');

  const ApiFailureType({
    required this.message,
  });

  final String message;
}
