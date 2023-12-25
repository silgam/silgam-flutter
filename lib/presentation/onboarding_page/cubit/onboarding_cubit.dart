import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/join_path.dart';
import '../../../repository/onboarding/onboarding_repository.dart';

part 'onboarding_cubit.freezed.dart';
part 'onboarding_state.dart';

@lazySingleton
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._onboardingRepository) : super(const OnboardingState());

  final OnboardingRepository _onboardingRepository;

  Future<bool> initialize() async {
    try {
      final joinPathsResult = await _onboardingRepository
          .getAllJoinPaths()
          .timeout(const Duration(seconds: 3));
      final joinPaths = joinPathsResult.tryGetSuccess() ?? [];
      if (joinPaths.isEmpty) return false;

      emit(state.copyWith(
        joinPaths: joinPaths,
      ));
      return true;
    } on TimeoutException {
      log('initialize timeout', name: 'OnboardingCubit.initialize');
      return false;
    }
  }

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

  void onJoinPathClicked(JoinPath joinPath) {
    final selectedJoinPathIds = [...state.selectedJoinPathIds];
    if (selectedJoinPathIds.contains(joinPath.id)) {
      selectedJoinPathIds.remove(joinPath.id);
    } else {
      selectedJoinPathIds.add(joinPath.id);
    }
    emit(state.copyWith(
      selectedJoinPathIds: selectedJoinPathIds,
    ));
  }
}
