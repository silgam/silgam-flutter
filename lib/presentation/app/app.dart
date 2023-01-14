import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../util/analytics_manager.dart';
import '../../util/injection.dart';
import '../clock_page/clock_page.dart';
import '../edit_record_page/edit_record_page.dart';
import '../home_page/home_page.dart';
import '../home_page/settings/noise_setting_page.dart';
import '../login_page/login_page.dart';
import '../purchase_page/purchase_page.dart';
import '../record_detail_page/record_detail_page.dart';
import '../review_problem_detail_page/review_problem_detail_page.dart';
import '../save_image_page/save_image_page.dart';
import 'cubit/app_cubit.dart';

const double cardCornerRadius = 14;

class SilgamApp extends StatelessWidget {
  const SilgamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initialize();
    return BlocProvider(
      create: (context) => getIt.get<AppCubit>(),
      child: MaterialApp(
        title: '실감',
        initialRoute: HomePage.routeName,
        routes: {
          HomePage.routeName: (_) => const HomePage(),
          LoginPage.routeName: (_) => const LoginPage(),
          NoiseSettingPage.routeName: (_) => const NoiseSettingPage(),
          PurchasePage.routeName: (_) => PurchasePage(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case ClockPage.routeName:
              final args = settings.arguments as ClockPageArguments;
              return MaterialPageRoute(
                builder: (_) => ClockPage(exam: args.exam),
                settings: settings,
              );
            case EditRecordPage.routeName:
              final args = settings.arguments as EditRecordPageArguments;
              return MaterialPageRoute(
                builder: (_) => EditRecordPage(arguments: args),
                settings: settings,
              );
            case RecordDetailPage.routeName:
              final args = settings.arguments as RecordDetailPageArguments;
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => RecordDetailPage(arguments: args),
                transitionsBuilder:
                    (_, Animation<double> animation, __, Widget child) =>
                        FadeTransition(opacity: animation, child: child),
                settings: settings,
              );
            case ReviewProblemDetailPage.routeName:
              final args =
                  settings.arguments as ReviewProblemDetailPageArguments;
              return MaterialPageRoute(
                builder: (_) =>
                    ReviewProblemDetailPage(reviewProblem: args.problem),
                settings: settings,
              );
            case SaveImagePage.routeName:
              final args = settings.arguments as SaveImagePageArguments;
              return MaterialPageRoute(
                builder: (_) => SaveImagePage(examRecord: args.recordToSave),
                settings: settings,
              );
          }
          return null;
        },
        theme: ThemeData(
          primarySwatch: indigoSwatch,
          fontFamily: 'NanumSquare',
          sliderTheme: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            trackShape: const RectangularSliderTrackShape(),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            overlayColor: Colors.transparent,
            thumbShape: SliderComponentShape.noThumb,
            showValueIndicator: ShowValueIndicator.always,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          physics: const BouncingScrollPhysics(),
        ),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          AnalyticsRouteObserver(),
        ],
      ),
    );
  }

  void initialize() {
    FirebaseMessaging.instance.requestPermission();
    initializeDateFormatting('ko_KR');
  }
}

const MaterialColor indigoSwatch = MaterialColor(
  _indigoPrimaryValue,
  <int, Color>{
    50: Color(0xFFE8EAF6),
    100: Color(0xFFC5CAE9),
    200: Color(0xFF9FA8DA),
    300: Color(0xFF7986CB),
    400: Color(0xFF5C6BC0),
    500: Color(0xFF3F51B5),
    600: Color(0xFF3949AB),
    700: Color(0xFF303F9F),
    800: Color(_indigoPrimaryValue),
    900: Color(0xFF1A237E),
  },
);
const int _indigoPrimaryValue = 0xFF283593;

const SystemUiOverlayStyle defaultSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.dark,
  statusBarColor: Colors.transparent,
  statusBarBrightness: Brightness.light,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.white,
);