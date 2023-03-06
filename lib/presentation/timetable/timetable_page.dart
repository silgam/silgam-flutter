import 'package:flutter/material.dart';
import 'package:silgam/presentation/app/app.dart';

import '../common/custom_menu_bar.dart';

class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  static const routeName = '/timetable';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: darkSystemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Column(
            children: const [
              CustomMenuBar(
                title: '전과목 시험보기',
                lightText: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
