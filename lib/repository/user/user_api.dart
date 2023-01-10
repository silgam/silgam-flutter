import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../model/user.dart';

part 'user_api.g.dart';

@lazySingleton
@RestApi()
abstract class UserApi {
  @factoryMethod
  factory UserApi(Dio dio) = _UserApi;

  @GET('/users/me')
  Future<User> getMe(@Header('Authorization') String bearerToken);
}
