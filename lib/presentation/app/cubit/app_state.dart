part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const AppState._();

  const factory AppState({
    User? me,
    @Default(ProductBenefit.initial) ProductBenefit productBenefit,
    @Default(ProductBenefit.initial) ProductBenefit freeProductBenefit,
    ConnectivityResult? connectivityResult,
  }) = _AppState;

  bool get isSignedIn => me != null;
  bool get isNotSignedIn => me == null;
}
