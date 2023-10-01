import 'dart:developer';
import 'dart:io';

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
  Dio get dio => Dio(BaseOptions(
        baseUrl: urlSilgamApi,
        contentType: Headers.jsonContentType,
      ))
        ..interceptors.add(PrettyDioLogger())
        ..interceptors.add(InterceptorsWrapper(
          onError: (e, handler) {
            log('Dio error: ${e.error}', name: 'DioInterceptor');

            final body = e.response?.data;
            ApiFailure failure;
            if (e.error is SocketException) {
              failure = ApiFailure.noNetwork();
            } else if (body is Map<String, dynamic>) {
              final message = body['message'] as String?;
              failure = ApiFailure(
                type: ApiFailureType.unknown,
                message: message ?? ApiFailureType.unknown.message,
              );
            } else {
              failure = ApiFailure.unknown();
            }

            handler.next(e.copyWith(
              error: failure,
            ));
          },
        ));
}
