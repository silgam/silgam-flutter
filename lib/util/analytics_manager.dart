import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_env.dart';

class AnalyticsManager {
  static final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;
  static late final Mixpanel _mixpanel;

  static Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final superProperties = {
      'Platform': Platform.isAndroid ? 'android' : 'ios',
      'Version': packageInfo.version,
      'Build Number': packageInfo.buildNumber,
    };

    await _firebaseAnalytics.setAnalyticsCollectionEnabled(kReleaseMode);
    await _firebaseAnalytics.setDefaultEventParameters(superProperties);

    _mixpanel = await Mixpanel.init(
      AppEnv.mixpanelToken,
      trackAutomaticEvents: true,
      optOutTrackingDefault: kDebugMode,
      superProperties: superProperties,
    );

    FirebaseAuth.instance.authStateChanges().listen((event) {
      registerUserProperties({'Firebase User ID': event?.uid});
    });
  }

  static Future<void> logEvent({required String name, Map<String, dynamic> properties = const {}}) async {
    _mixpanel.track(name, properties: properties);
    await _firebaseAnalytics.logEvent(name: name, parameters: properties);
  }

  static void eventStartTime({required String name}) {
    _mixpanel.timeEvent(name);
  }

  static Future<void> registerUserProperties(Map<String, dynamic> properties) async {
    _mixpanel.registerSuperProperties(properties);
    await _firebaseAnalytics.setDefaultEventParameters(properties);
  }
}

class AnalyticsRouteObserver extends RouteObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    AnalyticsManager.logEvent(
      name: 'Page Open',
      properties: {'Page Name': route.settings.name},
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    AnalyticsManager.logEvent(
      name: 'Page Close',
      properties: {'Route': route.settings.name},
    );
  }
}
