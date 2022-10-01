import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../repository/user_repository.dart';
import '../edit_record_page/edit_record_page.dart';
import 'main/main_view.dart';
import 'record_list/record_list_view.dart';
import 'settings/settings_view.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';
  static final backgroundColor = Colors.grey[50];

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final StreamController<RecordListViewEvent> _recordListViewEventStreamController = StreamController.broadcast();
  final StreamController<SettingsViewEvent> _settingsViewEventStreamController = StreamController.broadcast();

  bool get _isNotSignedIn => UserRepository().isNotSignedIn();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((_) {
      _recordListViewEventStreamController.add(RecordListViewEvent.refreshUser);
      _settingsViewEventStreamController.add(SettingsViewEvent.refreshUser);
      setState(() {});
    });
  }

  void _onItemTapped(int index) {
    FirebaseAnalytics.instance.logEvent(
      name: 'home_page_tab_selected',
      parameters: {'index': index},
    );

    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        _recordListViewEventStreamController.add(RecordListViewEvent.refresh);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: defaultSystemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: HomePage.backgroundColor,
        body: SafeArea(
          child: IndexedStack(
            alignment: Alignment.center,
            index: _selectedIndex,
            sizing: StackFit.expand,
            children: [
              MainView(navigateToRecordTab: () => _onItemTapped(1)),
              RecordListView(eventStream: _recordListViewEventStreamController.stream),
              SettingsView(eventStream: _settingsViewEventStreamController.stream),
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
          items: const [
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
          ],
        ),
        floatingActionButton: _selectedIndex == 1 && !_isNotSignedIn
            ? FloatingActionButton(
                onPressed: _onAddExamRecordButtonPressed,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _recordListViewEventStreamController.close();
    _settingsViewEventStreamController.close();
    super.dispose();
  }

  void _onAddExamRecordButtonPressed() async {
    final args = EditRecordPageArguments();
    await Navigator.pushNamed(context, EditRecordPage.routeName, arguments: args);
    _recordListViewEventStreamController.add(RecordListViewEvent.refresh);
  }
}
