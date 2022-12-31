import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../model/auth.dart';

const apiUrl = 'https://asia-northeast3-silgam-app.cloudfunctions.net/api';

@lazySingleton
class AuthRepository {
  Future<String> getFirebaseToken(OAuthToken kakaoOAuthToken) async {
    final url = Uri.parse('$apiUrl/auth/kakao');
    final response =
        await http.post(url, body: {'token': kakaoOAuthToken.accessToken});
    final authResponse = AuthResponse.fromJsonString(response.body);
    return authResponse.firebaseToken;
  }
}
