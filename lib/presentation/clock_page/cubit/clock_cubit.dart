import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'clock_cubit.freezed.dart';
part 'clock_state.dart';

@injectable
class ClockCubit extends Cubit<ClockState> {
  ClockCubit() : super(const ClockState());

  void onScreenTap() {
    emit(state.copyWith(isUiVisible: !state.isUiVisible));
  }

  void startExam() {
    emit(state.copyWith(isStarted: true));
  }
}
