import 'dart:developer';
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
      setUserId(userId: event?.uid);
      setPeopleProperty("\$name", event?.uid);
      setPeopleProperty('\$email', event?.email);
    });
  }

  static Future<void> logEvent({required String name, Map<String, dynamic> properties = const {}}) async {
    log('Event Logged: $name, $properties');
    _mixpanel.track(name, properties: properties);

    String firebaaseEventName = name.replaceAll(' ', '_').replaceAll('[', '').replaceAll(']', '');
    Map<String, dynamic> firebaseProperties = properties.map((key, value) => MapEntry(key.replaceAll(' ', '_'), value));
    await _firebaseAnalytics.logEvent(name: firebaaseEventName, parameters: firebaseProperties);
  }

  static void eventStartTime({required String name}) {
    _mixpanel.timeEvent(name);
  }

  static Future<void> registerUserProperties(Map<String, dynamic> properties) async {
    _mixpanel.registerSuperProperties(properties);
    await _firebaseAnalytics.setDefaultEventParameters(properties);
  }

  static Future<void> setUserId({required String? userId}) async {
    if (userId != null) _mixpanel.identify(userId);
    await _firebaseAnalytics.setUserId(id: userId);
  }

  static setPeopleProperty(String prop, dynamic to) {
    _mixpanel.getPeople().set(prop, to);
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
