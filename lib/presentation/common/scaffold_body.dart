import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../util/analytics_manager.dart';
import '../../util/const.dart';
import '../app/app.dart';

class ScaffoldBody extends StatelessWidget {
  final String title;
  final List<Widget> slivers;
  final RefreshCallback? onRefresh;
  final bool isRefreshing;

  const ScaffoldBody({
    super.key,
    required this.title,
    required this.slivers,
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding;
    if (screenWidth > tabletScreenWidth) {
      final originalHorizontalPadding = screenWidth > 1000 ? 80.0 : 50.0;
      horizontalPadding = max(
        (screenWidth - maxWidthForTablet) / 2,
        originalHorizontalPadding,
      );
    } else {
      horizontalPadding = max((screenWidth - maxWidth) / 2, 20.0);
    }
    const systemOverlayStyle = SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    );

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          toolbarHeight: 80,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(bottom: 16, left: horizontalPadding),
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
                margin: EdgeInsets.only(top: 12, right: horizontalPadding),
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
          backgroundColor: SilgamApp.backgroundColor,
          // Because of this https://github.com/flutter/flutter/issues/24893
          systemOverlayStyle:
              kIsWeb || Platform.isIOS ? null : systemOverlayStyle,
        ),
        ...slivers.map((sliver) {
          if (sliver is NonPaddingChildBuilder) {
            return (sliver).builder(horizontalPadding);
          }
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: sliver,
          );
        }),
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

class NonPaddingChildBuilder extends StatelessWidget {
  final Widget Function(double horizontalPadding) builder;

  const NonPaddingChildBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
