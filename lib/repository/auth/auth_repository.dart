import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:multiple_result/multiple_result.dart';

import '../../util/api_failure.dart';
import 'auth_api.dart';
import 'dto/auth_dto.dart';

@lazySingleton
class AuthRepository {
  const AuthRepository(this._authApi);

  final AuthApi _authApi;

  Future<Result<String, ApiFailure>> authKakao(kakao.OAuthToken kakaoOAuthToken) async {
    final requestBody = AuthRequest(token: kakaoOAuthToken.accessToken);
    try {
      final response = await _authApi.authKakao(requestBody);
      return Result.success(response.firebaseToken);
    } on DioException catch (e) {
      log(e.toString(), name: 'AuthRepository.authKakao');
      return Result.error(e.error as ApiFailure);
    }
  }
}
