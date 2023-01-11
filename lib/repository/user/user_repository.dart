import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:injectable/injectable.dart';

import '../../model/user.dart';
import 'user_api.dart';

@lazySingleton
class UserRepository {
  UserRepository(this._userApi);

  final UserApi _userApi;

  Future<User?> getMe() async {
    final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (authToken == null) {
      log('getMe() failed: firebase token is null', name: 'UserRepository');
      return null;
    }

    try {
      return _userApi.getMe('Bearer $authToken');
    } catch (e) {
      log('getMe() failed: $e', name: 'UserRepository');
      return null;
    }
  }
}
