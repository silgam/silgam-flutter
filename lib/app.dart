import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'clock_page/clock_page.dart';
import 'edit_record_page/edit_record_page.dart';
import 'home_page/home_page.dart';
import 'login_page/login_page.dart';

class SilgamApp extends StatelessWidget {
  const SilgamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initialize();
    return MaterialApp(
      title: '실감',
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        LoginPage.routeName: (context) => const LoginPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case ClockPage.routeName:
            final args = settings.arguments as ClockPageArguments;
            return MaterialPageRoute(
              builder: (context) => ClockPage(exam: args.exam),
            );
          case EditRecordPage.routeName:
            final args = settings.arguments as EditRecordPageArguments;
            return MaterialPageRoute(
              builder: (context) => EditRecordPage(arguments: args),
            );
        }
      },
      theme: ThemeData(
        primarySwatch: indigoSwatch,
        fontFamily: 'NotoSansKR',
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  void initialize() {
    FirebaseMessaging.instance.requestPermission();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
    );
    initializeDateFormatting('ko_KR');
  }
}

const MaterialColor indigoSwatch = MaterialColor(
  _indigoPrimaryValue,
  <int, Color>{
    50: Color(0xFFE8EAF6),
    100: Color(0xFFC5CAE9),
    200: Color(0xFF9FA8DA),
    300: Color(0xFF7986CB),
    400: Color(0xFF5C6BC0),
    500: Color(0xFF3F51B5),
    600: Color(0xFF3949AB),
    700: Color(0xFF303F9F),
    800: Color(_indigoPrimaryValue),
    900: Color(0xFF1A237E),
  },
);
const int _indigoPrimaryValue = 0xFF283593;
