part of 'customize_subject_name_cubit.dart';

enum CustomizeSubjectNameStatus {
  initial,
  saving,
  saved,
}

@freezed
class CustomizeSubjectNameState with _$CustomizeSubjectNameState {
  const factory CustomizeSubjectNameState({
    @Default(CustomizeSubjectNameStatus.initial)
    CustomizeSubjectNameStatus status,
    @Default(false) bool isFormChanged,
  }) = _CustomizeSubjectNameState;
}
