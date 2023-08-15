import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'app_env.dart';
import 'firebase_options.dart';
import 'presentation/app/app.dart';
import 'presentation/app/cubit/app_cubit.dart';
import 'presentation/app/cubit/iap_cubit.dart';
import 'presentation/home_page/main/cubit/main_cubit.dart';
import 'util/analytics_manager.dart';
import 'util/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: AppEnv.kakaoNativeAppKey);

  await configureDependencies();
  await Future.wait([
    initializeFirebase(),
    if (!kIsWeb) MobileAds.instance.initialize(),
    initializeAudioSession(),
  ]);

  runApp(const SilgamApp());
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AnalyticsManager.init();

  getIt.get<IapCubit>().initialize();
  getIt.get<MainCubit>().initialize();

  await Future.wait([
    getIt.get<AppCubit>().initialize(),
    if (!kIsWeb)
      FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(kReleaseMode),
  ]);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> initializeAudioSession() async {
  final AudioSession audioSession = await AudioSession.instance;
  await audioSession.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
  ));
}
