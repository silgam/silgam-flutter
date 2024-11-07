import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'settings_cubit.freezed.dart';
part 'settings_state.dart';

@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void preferenceUpdated(String preferenceKey) {
    emit(state.copyWith(updatedPreferenceKey: preferenceKey));
  }
}
