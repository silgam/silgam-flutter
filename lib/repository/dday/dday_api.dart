import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../model/dday.dart';

part 'dday_api.g.dart';

@lazySingleton
@RestApi()
abstract class DDayApi {
  @factoryMethod
  factory DDayApi(Dio dio) = _DDayApi;

  @GET('/ddays')
  Future<List<DDay>> getAllDDays();
}
