import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _backgroundColor = Colors.grey[50];

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '시험보기',
          style: TextStyle(
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
      backgroundColor: _backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 4,
        backgroundColor: Colors.white,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: '시험보기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
