import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'app.dart';
import 'app_env.dart';
import 'firebase_options.dart';
import 'util/analytics_manager.dart';
import 'util/shared_preferences_holder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);
  await SharedPreferencesHolder.initializeSharedPreferences();
  await MobileAds.instance.initialize();
  await AnalyticsManager.init();

  KakaoSdk.init(nativeAppKey: AppEnv.kakaoNativeAppKey);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const SilgamApp());
}
