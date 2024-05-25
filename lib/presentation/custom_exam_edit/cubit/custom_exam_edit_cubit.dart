import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_exam_edit_cubit.freezed.dart';
part 'custom_exam_edit_state.dart';

class CustomExamEditCubit extends Cubit<CustomExamEditState> {
  CustomExamEditCubit() : super(const CustomExamEditState.initial());
}
