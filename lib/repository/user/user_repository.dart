import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:injectable/injectable.dart';

import '../../model/user.dart';
import 'user_api.dart';

@lazySingleton
class UserRepository {
  UserRepository(this._userApi);

  final UserApi _userApi;

  Future<User> getMe() async {
    final authToken =
        await firebase.FirebaseAuth.instance.currentUser?.getIdToken();
    return _userApi.getMe('Bearer $authToken');
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
