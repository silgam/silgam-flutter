part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const AppState._();

  const factory AppState({
    User? me,
    @Default(ProductBenefit.initial) ProductBenefit productBenefit,
    @Default(ProductBenefit.initial) ProductBenefit freeProductBenefit,
    @Default(false) bool isOffline,
    @Default([]) List<Exam> customExams,
  }) = _AppState;

  bool get isSignedIn => me != null;
  bool get isNotSignedIn => me == null;

  Map<Subject, String>? get customSubjectNameMap {
    if (productBenefit.isCustomSubjectNameAvailable) {
      return me?.customSubjectNameMap;
    }
    return null;
  }
}
