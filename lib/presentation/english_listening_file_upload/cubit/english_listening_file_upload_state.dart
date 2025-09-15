part of 'english_listening_file_upload_cubit.dart';

@freezed
class EnglishListeningFileUploadState with _$EnglishListeningFileUploadState {
  const factory EnglishListeningFileUploadState({
    List<double>? waveformData,
    @Default(false) bool isPlaying,
  }) = _EnglishListeningFileUploadState;
}
