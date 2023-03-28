part of 'customize_subject_name_cubit.dart';

@freezed
class CustomizeSubjectNameState with _$CustomizeSubjectNameState {
  const factory CustomizeSubjectNameState({
    @Default({}) Map<Subject, String> subjectNameMap,
    @Default(false) bool isSaved,
  }) = _CustomizeSubjectNameState;
}
