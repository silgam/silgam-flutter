import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../edit_record_page/edit_record_page.dart';
import '../repository/user_repository.dart';
import 'record_list/record_list_view.dart';
import 'settings_view.dart';
import 'take_exam_view.dart';

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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: defaultSystemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: HomePage.backgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          sizing: StackFit.expand,
          children: [
            TakeExamView(navigateToRecordTab: () => _onItemTapped(1)),
            RecordListView(eventStream: _recordListViewEventStreamController.stream),
            SettingsView(eventStream: _settingsViewEventStreamController.stream),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 4,
          backgroundColor: Colors.white,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: TakeExamView.title,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: RecordListView.title,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
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
