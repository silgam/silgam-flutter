import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';

import 'app.dart';
import 'util/shared_preferences_holder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(kReleaseMode);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);
  await SharedPreferencesHolder.initializeSharedPreferences();
  KakaoContext.clientId = '75edb119450e8355c4506a8623a2010e';
  runApp(const SilgamApp());
}
