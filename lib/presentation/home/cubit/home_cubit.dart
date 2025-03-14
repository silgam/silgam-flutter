import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../home_page.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

@lazySingleton
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  static const defaultTabIndex = 0;

  void changeTab(int tabIndex) {
    emit(state.copyWith(tabIndex: tabIndex));
  }

  void changeTabByTitle(String title) {
    final tabIndex = HomePage.views.keys.toList().indexOf(title);
    changeTab(tabIndex);
  }
}
