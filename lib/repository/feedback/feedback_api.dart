import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import 'dto/send_feedback_request.dto.dart';

part 'feedback_api.g.dart';

@lazySingleton
@RestApi()
abstract class FeedbackApi {
  @factoryMethod
  factory FeedbackApi(Dio dio) = _FeedbackApi;

  @POST('/feedback')
  Future<void> sendFeedback(@Body() SendFeedbackRequestDto request);
}
