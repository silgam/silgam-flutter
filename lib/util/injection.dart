import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_failure.dart';
import 'const.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => getIt.init();

@module
abstract class RegisterModule {
  @singleton
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @singleton
  Dio get dio => Dio(BaseOptions(baseUrl: urlSilgamApi))
    ..interceptors.add(PrettyDioLogger())
    ..interceptors.add(InterceptorsWrapper(
      onError: (e, handler) {
        final body = e.response?.data;
        FailureBody failureBody;
        if (body is Map<String, dynamic>) {
          failureBody = FailureBody.fromJson(body);
        } else {
          failureBody = FailureBody.unknown();
        }

        handler.next(e.copyWith(
          error: ApiFailure(failureBody.message),
        ));
      },
    ));
}
