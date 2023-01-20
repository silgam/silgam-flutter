import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../model/user.dart';
import '../../util/api_failure.dart';
import 'user_api.dart';

@lazySingleton
class UserRepository {
  UserRepository(this._userApi);

  final UserApi _userApi;
  final CollectionReference<User> _usersRef =
      FirebaseFirestore.instance.collection('users').withConverter(
            fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
            toFirestore: (user, _) => user.toJson(),
          );

  Future<Result<User, ApiFailure>> getMe() async {
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (authToken == null) {
      log('getMe() failed: firebase token is null', name: 'UserRepository');
      return Result.error(const ApiFailure('인증에 실패했습니다. 앱을 다시 실행해주세요.'));
    }

    try {
      final me = await _userApi.getMe('Bearer $authToken');
      return Result.success(me);
    } on DioError catch (e) {
      log('getMe() failed: $e', name: 'UserRepository');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<Result<Unit, ApiFailure>> addFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      await _usersRef.doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([fcmToken]),
      });
      return Result.success(unit);
    } catch (e) {
      log('addFcmToken() failed: $e', name: 'UserRepository');
      return Result.error(ApiFailure.from(FailureBody.unknown()));
    }
  }

  Future<Result<Unit, ApiFailure>> removeFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      await _usersRef.doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([fcmToken]),
      });
      return Result.success(unit);
    } catch (e) {
      log('removeFcmToken() failed: $e', name: 'UserRepository');
      return Result.error(ApiFailure.from(FailureBody.unknown()));
    }
  }
}
