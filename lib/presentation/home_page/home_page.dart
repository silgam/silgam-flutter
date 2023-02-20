import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/injection.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../edit_record_page/edit_record_page.dart';
import 'cubit/home_cubit.dart';
import 'main/main_view.dart';
import 'record_list/record_list_view.dart';
import 'settings/settings_view.dart';
import 'stat/stat_view.dart';

class HomePageView {
  final Widget Function() viewBuilder;
  final BottomNavigationBarItem bottomNavigationBarItem;

  HomePageView({
    required this.viewBuilder,
    required this.bottomNavigationBarItem,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/';
  static final backgroundColor = Colors.grey[50];
  static final views = {
    MainView.title: HomePageView(
      viewBuilder: () => const MainView(),
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: MainView.title,
      ),
    ),
    RecordListView.title: HomePageView(
      viewBuilder: () => const RecordListView(),
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.view_list_outlined),
        activeIcon: Icon(Icons.view_list),
        label: RecordListView.title,
      ),
    ),
    StatView.title: HomePageView(
      viewBuilder: () => const StatView(),
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart_outlined),
        activeIcon: Icon(Icons.bar_chart),
        label: StatView.title,
      ),
    ),
    SettingsView.title: HomePageView(
      viewBuilder: () => const SettingsView(),
      bottomNavigationBarItem: const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: SettingsView.title,
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt.get<HomeCubit>(),
      child: AnnotatedRegion(
        value: defaultSystemUiOverlayStyle,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();
            return WillPopScope(
              onWillPop: cubit.onBackButtonPressed,
              child: Scaffold(
                backgroundColor: HomePage.backgroundColor,
                body: SafeArea(
                  child: IndexedStack(
                    alignment: Alignment.center,
                    index: state.tabIndex,
                    children: views.values
                        .map((view) => view.viewBuilder())
                        .toList(growable: false),
                  ),
                ),
                bottomNavigationBar: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BottomNavigationBar(
                      elevation: 4,
                      backgroundColor: Colors.white,
                      unselectedItemColor: Colors.grey,
                      showUnselectedLabels: false,
                      showSelectedLabels: false,
                      type: BottomNavigationBarType.fixed,
                      onTap: cubit.changeTab,
                      currentIndex: state.tabIndex,
                      landscapeLayout:
                          BottomNavigationBarLandscapeLayout.centered,
                      items: views.values
                          .map((view) => view.bottomNavigationBarItem)
                          .toList(growable: false),
                    ),
                    BlocBuilder<AppCubit, AppState>(
                      buildWhen: (previous, current) =>
                          previous.connectivityResult !=
                          current.connectivityResult,
                      builder: (context, state) {
                        if (state.connectivityResult !=
                            ConnectivityResult.none) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          color: Theme.of(context).primaryColor,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: const Text(
                            '오프라인 상태에선 일부 기능만 사용 가능해요',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
                floatingActionButton: BlocBuilder<AppCubit, AppState>(
                  buildWhen: (previous, current) =>
                      previous.isSignedIn != current.isSignedIn,
                  builder: (context, appState) {
                    final recordListTabIndex =
                        views.keys.toList().indexOf(RecordListView.title);
                    return state.tabIndex == recordListTabIndex &&
                            appState.isSignedIn
                        ? FloatingActionButton(
                            onPressed: () =>
                                _onAddExamRecordButtonPressed(context),
                            child: const Icon(Icons.add),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onAddExamRecordButtonPressed(BuildContext context) async {
    final args = EditRecordPageArguments();
    await Navigator.pushNamed(
      context,
      EditRecordPage.routeName,
      arguments: args,
    );
  }
}
