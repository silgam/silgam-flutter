import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const TakeExamView();
      case 1:
        return const RecordView();
      case 2:
        return const SettingsView();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: HomePage.backgroundColor,
        body: _buildBody(),
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
      ),
    );
  }
}
