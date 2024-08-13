import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../model/join_path.dart';
import '../../util/api_failure.dart';
import 'dto/submit_join_paths_request_dto.dart';
import 'onboarding_api.dart';

@lazySingleton
class OnboardingRepository {
  const OnboardingRepository(this._onboardingApi);

  final OnboardingApi _onboardingApi;

  Future<Result<List<JoinPath>, ApiFailure>> getAllJoinPaths() async {
    try {
      final joinPaths = await _onboardingApi.getAllJoinPaths();
      return Result.success(joinPaths);
    } on DioException catch (e) {
      log(e.toString(), name: 'OnboardingRepository.getAllJoinPaths');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<Result<Unit, ApiFailure>> submitJoinPaths({
    required List<String> joinPathIds,
    required String? otherJoinPath,
    required bool isSkipped,
  }) async {
    final request = SubmitJoinPathsRequestDto(
      joinPathIds: joinPathIds,
      userId: FirebaseAuth.instance.currentUser?.uid,
      otherJoinPath: otherJoinPath,
      isSkipped: isSkipped,
    );
    try {
      await _onboardingApi.submitJoinPaths(request);
      return const Result.success(unit);
    } on DioException catch (e) {
      log(e.toString(), name: 'OnboardingRepository.submitJoinPaths');
      return Result.error(e.error as ApiFailure);
    }
  }
}
