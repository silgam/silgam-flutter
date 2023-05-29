import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'exam_overview_cubit.freezed.dart';
part 'exam_overview_state.dart';

@injectable
class ExamOverviewCubit extends Cubit<ExamOverviewState> {
  ExamOverviewCubit() : super(const ExamOverviewState());
}
