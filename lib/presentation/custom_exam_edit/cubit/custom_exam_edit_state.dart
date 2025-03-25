part of 'custom_exam_edit_cubit.dart';

@freezed
class CustomExamEditState with _$CustomExamEditState {
  const factory CustomExamEditState({
    @Default(false) final bool showListeningEndAnnouncementEnabledField,
  }) = _CustomExamEditState;
}
