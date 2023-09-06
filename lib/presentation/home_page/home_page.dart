import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/injection.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../common/dialog.dart';
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

class HomePage extends StatefulWidget {
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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeCubit _cubit = getIt.get();
  bool isMarketingInfoReceivingConsentDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    _onMeChanged();
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) => previous.me != current.me,
        listener: (context, appState) {
          _onMeChanged();
        },
        child: AnnotatedRegion(
          value: defaultSystemUiOverlayStyle,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return WillPopScope(
                onWillPop: _cubit.onBackButtonPressed,
                child: Scaffold(
                  backgroundColor: HomePage.backgroundColor,
                  body: SafeArea(
                    child: IndexedStack(
                      alignment: Alignment.center,
                      index: state.tabIndex,
                      children: HomePage.views.values
                          .map((view) => view.viewBuilder())
                          .toList(growable: false),
                    ),
                  ),
                  bottomNavigationBar: BlocBuilder<AppCubit, AppState>(
                    buildWhen: (previous, current) =>
                        previous.isOffline != current.isOffline,
                    builder: (context, appState) {
                      return SafeArea(
                        bottom: appState.isOffline,
                        child: Column(
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
                              onTap: _cubit.changeTab,
                              currentIndex: state.tabIndex,
                              landscapeLayout:
                                  BottomNavigationBarLandscapeLayout.centered,
                              items: HomePage.views.values
                                  .map((view) => view.bottomNavigationBarItem)
                                  .toList(growable: false),
                            ),
                            !appState.isOffline
                                ? const SizedBox.shrink()
                                : Container(
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
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                  floatingActionButton: BlocBuilder<AppCubit, AppState>(
                    buildWhen: (previous, current) =>
                        previous.isSignedIn != current.isSignedIn,
                    builder: (context, appState) {
                      final recordListTabIndex = HomePage.views.keys
                          .toList()
                          .indexOf(RecordListView.title);
                      return state.tabIndex == recordListTabIndex &&
                              appState.isSignedIn
                          ? FloatingActionButton(
                              onPressed: () => _onAddExamRecordButtonPressed(),
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
      ),
    );
  }

  void _onMeChanged() {
    final me = context.read<AppCubit>().state.me;
    if (me == null) return;

    if (me.isMarketingInfoReceivingConsented == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (isMarketingInfoReceivingConsentDialogShowing) return;
        isMarketingInfoReceivingConsentDialogShowing = true;
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        await showMarketingInfoReceivingConsentDialog(context);
        isMarketingInfoReceivingConsentDialogShowing = false;
      });
    }
  }

  void _onAddExamRecordButtonPressed() async {
    final args = EditRecordPageArguments();
    await Navigator.pushNamed(
      context,
      EditRecordPage.routeName,
      arguments: args,
    );
  }
}
