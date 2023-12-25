import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'onboarding_cubit.freezed.dart';
part 'onboarding_state.dart';

@lazySingleton
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void next() {
    OnboardingStep nextStep;
    switch (state.step) {
      case OnboardingStep.welcome:
        nextStep = OnboardingStep.joinPath;
        break;
      case OnboardingStep.joinPath:
        nextStep = OnboardingStep.finished;
        break;
      case OnboardingStep.finished:
        nextStep = OnboardingStep.finished;
        break;
    }
    emit(state.copyWith(
      step: nextStep,
    ));
  }

  void skip() {
    emit(state.copyWith(
      step: OnboardingStep.finished,
    ));
  }
}
