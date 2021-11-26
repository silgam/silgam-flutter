import 'package:flutter/material.dart';

import 'clock_page.dart';

class SilgamApp extends StatelessWidget {
  const SilgamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '실감',
      initialRoute: '/clock',
      routes: {
        '/clock': (context) => const ClockPage(),
      },
      theme: ThemeData(fontFamily: 'NotoSansKR'),
      debugShowCheckedModeBanner: false,
    );
  }
}
