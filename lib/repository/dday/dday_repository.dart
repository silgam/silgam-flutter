import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../model/dday.dart';
import '../../util/api_failure.dart';
import 'dday_api.dart';

@lazySingleton
class DDayRepository {
  DDayRepository(this._ddayApi);

  final DDayApi _ddayApi;

  Future<Result<List<DDay>, ApiFailure>> getAllDDays() async {
    try {
      final ddays = await _ddayApi.getAllDDays();
      final ddaysLocal = ddays
          .map(
            (dday) => dday.copyWith(
              date: dday.date.toLocal(),
            ),
          )
          .toList();
      return Result.success(ddaysLocal);
    } on DioException catch (e) {
      log(e.toString(), name: 'DDayRepository.getAllDDays');
      return Result.error(e.error as ApiFailure);
    }
  }
}
