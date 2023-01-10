import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../repository/user/user_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/injection.dart';
import '../edit_record_page/edit_record_page.dart';
import 'main/main_view.dart';
import 'record_list/record_list_view.dart';
import 'settings/settings_view.dart';

const bottomNavBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home),
    label: MainView.title,
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.view_list_outlined),
    activeIcon: Icon(Icons.view_list),
    label: RecordListView.title,
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings_outlined),
    activeIcon: Icon(Icons.settings),
    label: SettingsView.title,
  ),
];

class HomePage extends StatefulWidget {
  static const routeName = '/';
  static final backgroundColor = Colors.grey[50];
  static final StreamController<RecordListViewEvent>
      recordListViewEventStreamController = StreamController.broadcast();

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

const _defaultPageIndex = 0;

class _HomePageState extends State<HomePage> {
  final UserRepository _userRepository = getIt.get();
  final StreamController<SettingsViewEvent> _settingsViewEventStreamController =
      StreamController.broadcast();

  int _selectedIndex = _defaultPageIndex;
  bool get _isNotSignedIn => _userRepository.isNotSignedIn();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((_) {
      HomePage.recordListViewEventStreamController
          .add(RecordListViewEvent.refreshUser);
      _settingsViewEventStreamController.add(SettingsViewEvent.refreshUser);
      setState(() {});
    });
  }

  void _onItemTapped(int index) {
    AnalyticsManager.logEvent(
      name: '[HomePage] Tab selected',
      properties: {
        'label': bottomNavBarItems[index].label,
        'index': index,
      },
    );

    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        HomePage.recordListViewEventStreamController
            .add(RecordListViewEvent.refresh);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: defaultSystemUiOverlayStyle,
      child: WillPopScope(
        onWillPop: _onBackButtonPressed,
        child: Scaffold(
          backgroundColor: HomePage.backgroundColor,
          body: SafeArea(
            child: IndexedStack(
              alignment: Alignment.center,
              index: _selectedIndex,
              sizing: StackFit.expand,
              children: [
                MainView(navigateToRecordTab: () => _onItemTapped(1)),
                const RecordListView(),
                SettingsView(
                    eventStream: _settingsViewEventStreamController.stream),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            elevation: 4,
            backgroundColor: Colors.white,
            showUnselectedLabels: false,
            showSelectedLabels: false,
            onTap: _onItemTapped,
            currentIndex: _selectedIndex,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            items: bottomNavBarItems,
          ),
          floatingActionButton: _selectedIndex == 1 && !_isNotSignedIn
              ? FloatingActionButton(
                  onPressed: _onAddExamRecordButtonPressed,
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _settingsViewEventStreamController.close();
    super.dispose();
  }

  Future<bool> _onBackButtonPressed() async {
    if (_selectedIndex == _defaultPageIndex) {
      return true;
    } else {
      _onItemTapped(_defaultPageIndex);
      return false;
    }
  }

  void _onAddExamRecordButtonPressed() async {
    final args = EditRecordPageArguments();
    await Navigator.pushNamed(context, EditRecordPage.routeName,
        arguments: args);
  }
}
