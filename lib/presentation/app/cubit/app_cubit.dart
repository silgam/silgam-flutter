import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../model/user.dart';
import '../../../repository/user/user_repository.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

@lazySingleton
class AppCubit extends Cubit<AppState> {
  AppCubit(this._userRepository) : super(const AppState()) {
    _initialize();
  }

  final UserRepository _userRepository;

  Future<void> updateMe() async {
    final me = await _userRepository.getMe();
    emit(state.copyWith(me: me));
  }

  void _initialize() {
    FirebaseAuth.instance.userChanges().listen((user) async {
      await updateMe();
    });
  }
}
