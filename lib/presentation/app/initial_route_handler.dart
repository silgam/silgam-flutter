import 'package:flutter/material.dart';

import '../home/home_page.dart';

class InitialRouteHandler extends StatelessWidget {
  const InitialRouteHandler(this._initialRoute, {super.key});

  final String _initialRoute;

  @override
  Widget build(BuildContext context) {
    final route = _initialRoute.contains('silgam.app')
        ? _initialRoute.split('silgam.app')[1]
        : _initialRoute;
    Future(() {
      if (!context.mounted) return;

      if (route != HomePage.routeName) {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
        Navigator.of(context).pushNamed(route);
      } else {
        Navigator.of(context).pushReplacementNamed(route);
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
