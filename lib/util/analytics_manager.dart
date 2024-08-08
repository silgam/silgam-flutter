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
  static final FirebaseAnalytics _firebaseAnalytics =
      FirebaseAnalytics.instance;
  static late final Mixpanel _mixpanel;

  static Future<void> init() async {
    if (kIsWeb) return;

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
      setPeopleProperties({
        '\$name': event?.uid,
        '\$email': event?.email,
      });
    });
  }

  static Future<void> logEvent({
    required String name,
    Map<String, dynamic> properties = const {},
  }) async {
    if (kIsWeb) return;

    log('Event Logged: $name, $properties');
    _mixpanel.track(name, properties: properties);

    String firebaseEventName = name
        .replaceAll(' ', '_')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('-', '_')
        .replaceAll('/', '_');
    Map<String, dynamic> firebaseProperties = properties.map(
      (key, value) => MapEntry(
        key.replaceAll(' ', '_'),
        value is String || value is num ? value : value.toString(),
      ),
    );
    await _firebaseAnalytics.logEvent(
      name: firebaseEventName,
      parameters: firebaseProperties,
    );
  }

  static void eventStartTime({required String name}) {
    if (kIsWeb) return;

    _mixpanel.timeEvent(name);
  }

  static Future<void> registerUserProperties(
      Map<String, dynamic> properties) async {
    if (kIsWeb) return;

    _mixpanel.registerSuperProperties(properties);
    await _firebaseAnalytics.setDefaultEventParameters(properties);
  }

  static Future<void> setUserId({required String? userId}) async {
    if (kIsWeb) return;

    if (userId != null) _mixpanel.identify(userId);
    await _firebaseAnalytics.setUserId(id: userId);
  }

  static void setPeopleProperty(String prop, dynamic to) {
    if (kIsWeb) return;

    log('People Property Set: $prop, $to');
    _mixpanel.getPeople().set(prop, to);
  }

  static void setPeopleProperties(Map<String, dynamic> properties) {
    if (kIsWeb) return;
    properties.forEach((key, value) {
      setPeopleProperty(key, value);
    });
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
