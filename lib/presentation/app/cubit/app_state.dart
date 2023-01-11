part of 'app_cubit.dart';

typedef FirebaseUser = firebase.User;

@freezed
class AppState with _$AppState {
  const AppState._();

  const factory AppState({
    User? me,
    FirebaseUser? firebaseUser,
  }) = _AppState;

  bool get isSignedIn => me != null;
  bool get isNotSignedIn => me == null;
}
