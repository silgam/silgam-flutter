part of 'onboarding_cubit.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(OnboardingStep.welcome) OnboardingStep step,
  }) = _OnboardingState;
}

enum OnboardingStep { welcome, joinPath, finished }
