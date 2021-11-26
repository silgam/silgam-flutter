import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _backgroundColor = Colors.grey[50];
const _tabItemNames = ['시험보기', '기록', '설정'];

class HomePage extends StatefulWidget {
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
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          _tabItemNames[_selectedIndex],
          style: const TextStyle(
            fontFamily: 'NanumMyeongjo',
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        titleSpacing: 24,
        toolbarHeight: 90,
        foregroundColor: Colors.black,
        backgroundColor: _backgroundColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: _backgroundColor, statusBarIconBrightness: Brightness.dark),
      ),
      body: _buildBody(),
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
