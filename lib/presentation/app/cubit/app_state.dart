part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const AppState._();

  const factory AppState({
    User? me,
    @Default(ProductBenefit.initial) ProductBenefit productBenefit,
    @Default(ProductBenefit.initial) ProductBenefit freeProductBenefit,
    @Default(false) bool isOffline,
  }) = _AppState;

  bool get isSignedIn => me != null;
  bool get isNotSignedIn => me == null;

  Map<Subject, String> get customSubjectNameMap {
    final me = this.me;
    if (me != null && productBenefit.isCustomSubjectNameAvailable) {
      return me.customSubjectNameMap ?? Subject.defaultSubjectNameMap;
    }
    return Subject.defaultSubjectNameMap;
  }
}
