import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../model/join_path.dart';
import 'dto/submit_join_paths_request_dto.dart';

part 'onboarding_api.g.dart';

@lazySingleton
@RestApi()
abstract class OnboardingApi {
  @factoryMethod
  factory OnboardingApi(Dio dio) = _OnboardingApi;

  @GET('/join_paths')
  Future<List<JoinPath>> getAllJoinPaths();

  @POST('/onboarding/join_paths')
  Future<void> submitJoinPaths(
    @Body() SubmitJoinPathsRequestDto request,
  );
}
