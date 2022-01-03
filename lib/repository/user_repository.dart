import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  UserRepository._privateConstructor();

  static final _instance = UserRepository._privateConstructor();

  factory UserRepository() => _instance;

  User getUser() {
    return FirebaseAuth.instance.currentUser!;
  }

  User? getUserOrNull() {
    return FirebaseAuth.instance.currentUser;
  }

  bool isNotSignedIn() => getUserOrNull() == null;
}
