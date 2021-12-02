import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home_page/home_page.dart';

class ScaffoldBody extends StatelessWidget {
  final String title;
  final Widget child;

  const ScaffoldBody({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          toolbarHeight: 80,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(bottom: 16, left: 20),
            centerTitle: false,
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'NanumMyeongjo',
                fontWeight: FontWeight.w800,
                fontSize: 28,
                color: Colors.black,
              ),
            ),
          ),
          foregroundColor: Colors.black,
          backgroundColor: HomePage.backgroundColor,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
          ),
        ),
        child,
      ],
    );
  }
}
