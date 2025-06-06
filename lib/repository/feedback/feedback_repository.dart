import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../util/api_failure.dart';
import 'dto/send_feedback_request.dto.dart';
import 'feedback_api.dart';

@lazySingleton
class FeedbackRepository {
  const FeedbackRepository(this._feedbackApi);

  final FeedbackApi _feedbackApi;

  Future<Result<Unit, ApiFailure>> sendFeedback({required String feedback}) async {
    final request = SendFeedbackRequestDto(
      userId: FirebaseAuth.instance.currentUser?.uid,
      feedback: feedback,
      appVersion: await _getAppVersion(),
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
    );
    try {
      await _feedbackApi.sendFeedback(request);
      return const Result.success(unit);
    } on DioException catch (e) {
      log(e.toString(), name: 'FeedbackRepository.sendFeedback');
      return Result.error(e.error as ApiFailure);
    }
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
