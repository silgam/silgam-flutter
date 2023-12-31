import 'package:audio_session/audio_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_env.dart';
import 'firebase_options.dart';
import 'presentation/app/app.dart';
import 'presentation/app/cubit/app_cubit.dart';
import 'presentation/app/cubit/iap_cubit.dart';
import 'presentation/home_page/home_page.dart';
import 'presentation/home_page/main/cubit/main_cubit.dart';
import 'presentation/onboarding_page/cubit/onboarding_cubit.dart';
import 'presentation/onboarding_page/onboarding_page.dart';
import 'util/analytics_manager.dart';
import 'util/const.dart';
import 'util/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: AppEnv.kakaoNativeAppKey);

  await configureDependencies();
  await Future.wait([
    initializeFirebase(),
    if (!kIsWeb && !isAdmobDisabled) MobileAds.instance.initialize(),
    initializeAudioSession(),
  ]);
  final initialRoute = await initializeInitialRoute();

  runApp(SilgamApp(initialRoute: initialRoute));
}

Future<String> initializeInitialRoute() async {
  final SharedPreferences sharedPreferences = getIt.get();
  final isOnboardingFinished =
      sharedPreferences.getBool(PreferenceKey.isOnboardingFinished) ?? false;
  if (isOnboardingFinished) return HomePage.routeName;

  final isOnboardingInitialized =
      await getIt.get<OnboardingCubit>().initialize();
  if (isOnboardingInitialized) return OnboardingPage.routeName;
  return HomePage.routeName;
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (useFirebaseEmulator) {
    FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

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
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
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
