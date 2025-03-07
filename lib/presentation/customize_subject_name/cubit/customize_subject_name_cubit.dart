import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/subject.dart';
import '../../../repository/user/user_repository.dart';
import '../../../util/analytics_manager.dart';
import '../../app/cubit/app_cubit.dart';

part 'customize_subject_name_cubit.freezed.dart';
part 'customize_subject_name_state.dart';

@injectable
class CustomizeSubjectNameCubit extends Cubit<CustomizeSubjectNameState> {
  CustomizeSubjectNameCubit(this._appCubit, this._userRepository)
    : super(const CustomizeSubjectNameState());

  final AppCubit _appCubit;
  final UserRepository _userRepository;

  void onFormChanged() {
    emit(state.copyWith(isFormChanged: true));
  }

  Future<void> save({required Map<Subject, String> subjectNames}) async {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast('오프라인 상태에서는 수정할 수 없어요.', dismissOnTap: true);
      return;
    }

    final me = _appCubit.state.me;
    if (me == null) {
      EasyLoading.showError('로그인이 필요합니다.', dismissOnTap: true);
      return;
    }

    emit(state.copyWith(status: CustomizeSubjectNameStatus.saving));

    await _userRepository.updateCustomSubjectNameMap(userId: me.id, subjectNameMap: subjectNames);
    await _appCubit.onUserChange();

    emit(state.copyWith(status: CustomizeSubjectNameStatus.saved));

    AnalyticsManager.logEvent(
      name: '[CustomizeSubjectNamePage] Subject Name Saved',
      properties: {'subjectNameMap': subjectNames.toString()},
    );
    AnalyticsManager.setPeopleProperty('Customized Subject Names', subjectNames.toString());
  }
}
