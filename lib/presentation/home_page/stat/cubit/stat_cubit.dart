import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../model/exam_record.dart';
import '../../../../util/injection.dart';
import '../../../app/cubit/app_cubit.dart';
import '../../record_list/cubit/record_list_cubit.dart';

part 'stat_cubit.freezed.dart';
part 'stat_state.dart';

@lazySingleton
class StatCubit extends Cubit<StatState> {
  StatCubit() : super(const StatState());

  final AppCubit _appCubit = getIt.get();
  final RecordListCubit _recordListCubit = getIt.get();

  void onOriginalRecordsUpdated(List<ExamRecord> records) {
    emit(state.copyWith(originalRecords: records));
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    if (_appCubit.state.isNotSignedIn) {
      emit(const StatState());
      return;
    }

    emit(state.copyWith(isLoading: true));
    await _recordListCubit.refresh();
    emit(state.copyWith(isLoading: false));
  }
}
