import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:injectable/injectable.dart';

import '../../model/user.dart';
import 'user_api.dart';

@lazySingleton
class UserRepository {
  UserRepository(this._userApi);

  final UserApi _userApi;

  Future<User?> getMe() async {
    final authToken =
        await firebase.FirebaseAuth.instance.currentUser?.getIdToken();
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

  firebase.User getUser() {
    return firebase.FirebaseAuth.instance.currentUser!;
  }

  firebase.User? getUserOrNull() {
    return firebase.FirebaseAuth.instance.currentUser;
  }

  bool isSignedIn() => getUserOrNull() != null;

  bool isNotSignedIn() => getUserOrNull() == null;
}
