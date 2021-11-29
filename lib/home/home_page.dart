import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'record_view.dart';
import 'settings_view.dart';
import 'take_exam_view.dart';

final _backgroundColor = Colors.grey[50];
const _tabItemNames = ['시험보기', '기록', '설정'];

class HomePage extends StatefulWidget {
  static const routeName = '/';

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
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            toolbarHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16, left: 20),
              centerTitle: false,
              title: Text(
                _tabItemNames[_selectedIndex],
                style: const TextStyle(
                  fontFamily: 'NanumMyeongjo',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
            ),
            foregroundColor: Colors.black,
            backgroundColor: _backgroundColor,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.transparent,
            ),
          ),
          _buildBody()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 4,
        backgroundColor: Colors.white,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.create),
            label: _tabItemNames[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.format_list_bulleted),
            label: _tabItemNames[1],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: _tabItemNames[2],
          ),
        ],
      ),
    );
  }
}
