import 'package:flutter/material.dart';

import 'clock_page.dart';
import 'home_page.dart';

class SilgamApp extends StatelessWidget {
  const SilgamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '실감',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/clock': (context) => const ClockPage(),
      },
      theme: ThemeData(
        primarySwatch: indigoSwatch,
        fontFamily: 'NotoSansKR',
      ),
      debugShowCheckedModeBanner: false,
    );
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
