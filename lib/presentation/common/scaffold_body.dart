import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../util/analytics_manager.dart';
import '../home_page/home_page.dart';

class ScaffoldBody extends StatelessWidget {
  final String title;
  final List<Widget> slivers;
  final RefreshCallback? onRefresh;
  final bool isRefreshing;

  const ScaffoldBody({
    Key? key,
    required this.title,
    required this.slivers,
    this.onRefresh,
    this.isRefreshing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const systemOverlayStyle = SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverAppBar(
          toolbarHeight: 80,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(bottom: 16, left: 20),
            centerTitle: false,
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            if (onRefresh != null)
              Container(
                margin: const EdgeInsets.only(right: 8, top: 12),
                alignment: Alignment.center,
                child: Builder(builder: (context) {
                  if (isRefreshing) {
                    return const IconButton(
                      onPressed: null,
                      icon: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      ),
                    );
                  } else {
                    return IconButton(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    );
                  }
                }),
              ),
          ],
          foregroundColor: Colors.black,
          backgroundColor: HomePage.backgroundColor,
          // Because of this https://github.com/flutter/flutter/issues/24893
          systemOverlayStyle: Platform.isIOS ? null : systemOverlayStyle,
        ),
        ...slivers,
      ],
    );
  }

  void _onRefresh() {
    onRefresh?.call();
    AnalyticsManager.logEvent(
      name: '[ScaffoldBody] Refresh',
      properties: {'page': title},
    );
  }
}
