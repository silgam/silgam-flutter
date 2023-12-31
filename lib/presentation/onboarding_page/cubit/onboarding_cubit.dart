import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/join_path.dart';
import '../../../repository/onboarding/onboarding_repository.dart';
import '../../../util/analytics_manager.dart';
import '../../../util/const.dart';

part 'onboarding_cubit.freezed.dart';
part 'onboarding_state.dart';

@lazySingleton
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._onboardingRepository, this._sharedPreferences)
      : super(const OnboardingState());

  final OnboardingRepository _onboardingRepository;
  final SharedPreferences _sharedPreferences;

  @override
  void onChange(Change<OnboardingState> change) async {
    super.onChange(change);
    if (change.nextState.step == OnboardingStep.finished) {
      await _sharedPreferences.setBool(
        PreferenceKey.isOnboardingFinished,
        true,
      );
    }
  }

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
    } catch (e) {
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
    AnalyticsManager.logEvent(
      name: '[Onboarding] Next',
      properties: {
        'next_step': nextStep.toString(),
      },
    );
  }

  void skip() {
    emit(state.copyWith(
      step: OnboardingStep.finished,
    ));
    _onboardingRepository.submitJoinPaths(
      isSkipped: true,
      joinPathIds: [],
      otherJoinPath: null,
    );
    AnalyticsManager.logEvent(name: '[Onboarding] Skip join path');
  }

  void submitJoinPath({required String otherJoinPath}) {
    emit(state.copyWith(
      step: OnboardingStep.finished,
    ));
    _onboardingRepository.submitJoinPaths(
      isSkipped: false,
      joinPathIds: state.selectedJoinPathIds,
      otherJoinPath: otherJoinPath,
    );
    AnalyticsManager.logEvent(
      name: '[Onboarding] Submit join path',
      properties: {
        'joinPathIds': state.selectedJoinPathIds,
        'otherJoinPath': otherJoinPath,
      },
    );
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
