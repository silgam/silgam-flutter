import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:injectable/injectable.dart';

@lazySingleton
class UserRepository {
  firebase.User getUser() {
    return firebase.FirebaseAuth.instance.currentUser!;
  }

  firebase.User? getUserOrNull() {
    return firebase.FirebaseAuth.instance.currentUser;
  }

  bool isSignedIn() => getUserOrNull() != null;

  bool isNotSignedIn() => getUserOrNull() == null;
}
