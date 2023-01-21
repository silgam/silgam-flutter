import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../util/analytics_manager.dart';
import '../home_page.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  static const defaultTabIndex = 0;

  void changeTab(int tabIndex) {
    emit(state.copyWith(tabIndex: tabIndex));
    AnalyticsManager.logEvent(
      name: '[HomePage] Tab selected',
      properties: {
        'label': HomePage.views.keys.toList()[tabIndex],
        'index': tabIndex,
      },
    );
  }

  void changeTabByTitle(String title) {
    final tabIndex = HomePage.views.keys.toList().indexOf(title);
    changeTab(tabIndex);
  }

  Future<bool> onBackButtonPressed() async {
    if (state.tabIndex == defaultTabIndex) {
      return true;
    } else {
      changeTab(defaultTabIndex);
      return false;
    }
  }
}
