import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'english_listening_file_upload_cubit.freezed.dart';
part 'english_listening_file_upload_state.dart';

@injectable
class EnglishListeningFileUploadCubit extends Cubit<EnglishListeningFileUploadState> {
  EnglishListeningFileUploadCubit() : super(const EnglishListeningFileUploadState());

  void updateWaveformData(List<double> waveformData) {
    emit(state.copyWith(waveformData: waveformData));
  }

  void togglePlayPause() {
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }
}
