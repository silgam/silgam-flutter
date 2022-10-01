import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'util/shared_preferences_holder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(kReleaseMode);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);
  await SharedPreferencesHolder.initializeSharedPreferences();
  KakaoSdk.init(nativeAppKey: "75edb119450e8355c4506a8623a2010e");
  MobileAds.instance.initialize();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await FirebaseAnalytics.instance.setDefaultEventParameters({
    'platform': Platform.isAndroid ? 'android' : 'ios',
    'version': packageInfo.version,
    'build_number': packageInfo.buildNumber,
  });

  runApp(const SilgamApp());
}
