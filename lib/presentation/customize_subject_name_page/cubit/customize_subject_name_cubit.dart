import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/subject.dart';
import '../../../repository/user/user_repository.dart';
import '../../app/cubit/app_cubit.dart';

part 'customize_subject_name_cubit.freezed.dart';
part 'customize_subject_name_state.dart';

@injectable
class CustomizeSubjectNameCubit extends Cubit<CustomizeSubjectNameState> {
  CustomizeSubjectNameCubit(
    this._appCubit,
    this._userRepository,
  ) : super(const CustomizeSubjectNameState()) {
    _initialize();
  }

  final AppCubit _appCubit;
  final UserRepository _userRepository;

  Future<void> onSaveButtonPressed(
    Map<Subject, String> subjectNameMap,
  ) async {
    emit(state.copyWith(subjectNameMap: subjectNameMap));

    final me = _appCubit.state.me;
    if (me == null) {
      EasyLoading.showError('로그인이 필요합니다.');
      return;
    }

    EasyLoading.show();
    await _userRepository.updateCustomSubjectNameMap(
      userId: me.id,
      subjectNameMap: subjectNameMap,
    );
    await _appCubit.onUserChange();
    emit(state.copyWith(isSaved: true));
    EasyLoading.dismiss();
  }

  void _initialize() {
    emit(state.copyWith(
      subjectNameMap: _appCubit.state.customSubjectNameMap,
    ));
  }
}
