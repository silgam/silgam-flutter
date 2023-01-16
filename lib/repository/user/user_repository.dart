import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:injectable/injectable.dart';

import '../../model/user.dart';
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

  Future<void> addFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    await _usersRef.doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([fcmToken]),
    });
  }

  Future<void> removeFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    await _usersRef.doc(userId).update({
      'fcmTokens': FieldValue.arrayRemove([fcmToken]),
    });
  }
}
