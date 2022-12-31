import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserRepository {
  User getUser() {
    return FirebaseAuth.instance.currentUser!;
  }

  User? getUserOrNull() {
    return FirebaseAuth.instance.currentUser;
  }

  bool isSignedIn() => getUserOrNull() != null;

  bool isNotSignedIn() => getUserOrNull() == null;
}
