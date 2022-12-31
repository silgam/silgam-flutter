import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import 'dto/auth_dto.dart';

part 'auth_api.g.dart';

@lazySingleton
@RestApi()
abstract class AuthApi {
  @factoryMethod
  factory AuthApi(Dio dio) = _AuthApi;

  @POST('/auth/kakao')
  Future<AuthResponse> authKakao(@Body() AuthRequest body);
}
