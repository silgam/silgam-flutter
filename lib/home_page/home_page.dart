import 'package:flutter/material.dart';

import '../app.dart';
import '../edit_record_page/edit_record_page.dart';
import 'record_view.dart';
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
          children: const [
            TakeExamView(),
            RecordView(),
            SettingsView(),
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
              icon: Icon(Icons.create),
              label: TakeExamView.title,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: RecordView.title,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: SettingsView.title,
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 1
            ? FloatingActionButton(
                onPressed: _onAddExamRecordButtonPressed,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  void _onAddExamRecordButtonPressed() {
    final args = EditRecordPageArguments();
    Navigator.pushNamed(context, EditRecordPage.routeName, arguments: args);
  }
}
