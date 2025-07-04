import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/injection.dart';
import '../../util/notification_manager.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../common/dialog.dart';
import '../edit_record/edit_record_page.dart';
import '../offline/offline_guide_page.dart';
import 'cubit/home_cubit.dart';
import 'main/main_view.dart';
import 'record_list/record_list_view.dart';
import 'settings/settings_view.dart';
import 'stat/stat_view.dart';

class HomePageView {
  final Widget Function() viewBuilder;
  final BottomNavigationBarItem bottomNavigationBarItem;

  HomePageView({required this.viewBuilder, required this.bottomNavigationBarItem});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/';
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
  void initState() {
    super.initState();

    _onMeChanged();
    NotificationManager.instance.initialize(context);
  }

  void _onMeChanged() {
    final me = context.read<AppCubit>().state.me;
    if (me == null) return;

    if (me.isMarketingInfoReceivingConsented == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (isMarketingInfoReceivingConsentDialogShowing) return;
        isMarketingInfoReceivingConsentDialogShowing = true;

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          await showMarketingInfoReceivingConsentDialog(context);
        }

        isMarketingInfoReceivingConsentDialogShowing = false;
      });
    }
  }

  void _onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) return;
    _cubit.changeTab(HomeCubit.defaultTabIndex);
  }

  void _onAddExamRecordButtonPressed() {
    Navigator.pushNamed(context, EditRecordPage.routeName);
  }

  void _onOfflineMessageTap() {
    Navigator.pushNamed(context, OfflineGuidePage.routeName);
  }

  Widget _buildBottomNavigationBar(HomeState state) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.isOffline != current.isOffline,
      builder: (context, appState) {
        return SafeArea(
          left: false,
          right: false,
          bottom: appState.isOffline,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.white,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: false,
                showSelectedLabels: false,
                type: BottomNavigationBarType.fixed,
                onTap: _cubit.changeTab,
                currentIndex: state.tabIndex,
                landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
                items: HomePage.views.values
                    .map((view) => view.bottomNavigationBarItem)
                    .toList(growable: false),
              ),
              !appState.isOffline
                  ? const SizedBox.shrink()
                  : InkWell(
                      onTap: _onOfflineMessageTap,
                      splashColor: Colors.transparent,
                      child: Ink(
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: const Text(
                            '오프라인 상태에선 일부 기능만 사용 가능해요.',
                            style: TextStyle(fontSize: 12, height: 1.2, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(HomeState state) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.isSignedIn != current.isSignedIn,
      builder: (context, appState) {
        final recordListTabIndex = HomePage.views.keys.toList().indexOf(RecordListView.title);

        return state.tabIndex == recordListTabIndex && appState.isSignedIn
            ? FloatingActionButton(
                onPressed: () => _onAddExamRecordButtonPressed(),
                child: const Icon(Icons.add),
              )
            : const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) =>
            (previous.me == null && current.me != null) ||
            previous.me?.isMarketingInfoReceivingConsented !=
                current.me?.isMarketingInfoReceivingConsented,
        listener: (context, appState) {
          _onMeChanged();
        },
        child: AnnotatedRegion(
          value: defaultSystemUiOverlayStyle,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return PopScope(
                canPop: state.tabIndex == HomeCubit.defaultTabIndex,
                onPopInvokedWithResult: _onPopInvokedWithResult,
                child: Scaffold(
                  body: SafeArea(
                    child: IndexedStack(
                      alignment: Alignment.center,
                      index: state.tabIndex,
                      children: HomePage.views.values
                          .map((view) => view.viewBuilder())
                          .toList(growable: false),
                    ),
                  ),
                  bottomNavigationBar: _buildBottomNavigationBar(state),
                  floatingActionButton: _buildFloatingActionButton(state),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
