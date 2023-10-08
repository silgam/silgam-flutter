import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/app/cubit/app_cubit.dart';
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
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 20),
      ))
        ..interceptors.add(PrettyDioLogger(responseBody: false))
        ..interceptors.add(InterceptorsWrapper(
          onResponse: (response, handler) {
            if (response.statusCode == 200) {
              getIt.get<AppCubit>().updateIsOffline(false);
            }
            handler.next(response);
          },
          onError: (e, handler) {
            log('Dio error: ${e.error}, type: ${e.type}',
                name: 'DioInterceptor');

            final body = e.response?.data;
            ApiFailure failure;
            if (e.error is SocketException ||
                e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.receiveTimeout) {
              failure = ApiFailure.noNetwork();
              getIt.get<AppCubit>().updateIsOffline(true);
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
