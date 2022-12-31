import 'package:injectable/injectable.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:silgam/repository/auth/dto/auth_dto.dart';

import 'auth_api.dart';

@lazySingleton
class AuthRepository {
  AuthRepository(this._authApi);

  final AuthApi _authApi;

  Future<String> getFirebaseToken(kakao.OAuthToken kakaoOAuthToken) async {
    final requestBody = AuthRequest(token: kakaoOAuthToken.accessToken);
    final response = await _authApi.authKakao(requestBody);
    return response.firebaseToken;
  }
}
