part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    User? me,
  }) = _AppState;
}
