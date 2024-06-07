import 'dart:math';

import 'package:flutter/material.dart';

import '../app/app.dart';
import '../common/custom_menu_bar.dart';

class OfflineGuidePage extends StatelessWidget {
  const OfflineGuidePage({super.key});

  static const routeName = '/offline_guide';
  static const _maxWidth = 550.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: defaultSystemUiOverlayStyle.copyWith(
        statusBarColor: Theme.of(context).primaryColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Column(
            children: [
              const CustomMenuBar(
                title: '오프라인 모드 이용 안내',
                lightText: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: max(0, (screenWidth - _maxWidth) / 2),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/offline_guide_1.png',
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/offline_guide_2.png',
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/offline_guide_3.png',
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
