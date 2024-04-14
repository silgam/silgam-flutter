import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../model/subject.dart';
import '../../repository/exam/exam_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/injection.dart';
import '../clock/clock_page.dart';
import '../common/progress_overlay.dart';
import '../customize_subject_name/customize_subject_name_page.dart';
import '../edit_record/edit_record_page.dart';
import '../exam_overview/exam_overview_page.dart';
import '../home/home_page.dart';
import '../login/login_page.dart';
import '../my/my_page.dart';
import '../noise_setting/noise_setting_page.dart';
import '../notification_setting/notification_setting_page.dart';
import '../offline/offline_guide_page.dart';
import '../onboarding/onboarding_page.dart';
import '../products/silgampass/silgampass_page.dart';
import '../purchase/purchase_page.dart';
import '../record_detail/record_detail_page.dart';
import '../review_problem_detail/review_problem_detail_page.dart';
import '../save_image/save_image_page.dart';
import '../timetable/timetable_page.dart';
import 'cubit/app_cubit.dart';
import 'cubit/iap_cubit.dart';

const double cardCornerRadius = 14;

class SilgamApp extends StatelessWidget {
  const SilgamApp({Key? key, required String initialRoute})
      : _initialRoute = initialRoute,
        super(key: key);

  static const backgroundColor = Color.fromARGB(255, 245, 246, 247);
  final String _initialRoute;

  @override
  Widget build(BuildContext context) {
    initialize();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt.get<AppCubit>(),
        ),
        BlocProvider.value(
          value: getIt.get<IapCubit>(),
        ),
      ],
      child: BlocSelector<AppCubit, AppState, Map<Subject, String>?>(
        selector: (state) => state.customSubjectNameMap,
        builder: (context, customSubjectNameMap) {
          for (final exam in defaultExams) {
            exam.name =
                customSubjectNameMap?[exam.subject] ?? exam.subject.defaultName;
          }
          return MaterialApp(
            title: '실감',
            initialRoute: _initialRoute,
            routes: {
              OnboardingPage.routeName: (_) => OnboardingPage(),
              LoginPage.routeName: (_) => const LoginPage(),
              NoiseSettingPage.routeName: (_) => const NoiseSettingPage(),
              MyPage.routeName: (_) => const MyPage(),
              NotificationSettingPage.routeName: (_) =>
                  const NotificationSettingPage(),
              TimetablePage.routeName: (_) => const TimetablePage(),
              CustomizeSubjectNamePage.routeName: (_) =>
                  CustomizeSubjectNamePage(),
              OfflineGuidePage.routeName: (_) => const OfflineGuidePage(),
              SilgampassPage.routeName: (_) => const SilgampassPage(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case HomePage.routeName:
                  return PageRouteBuilder(
                    settings: settings,
                    pageBuilder: (_, __, ___) => const HomePage(),
                    transitionDuration: const Duration(milliseconds: 800),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  );
                case ClockPage.routeName:
                  final args = settings.arguments as ClockPageArguments;
                  return MaterialPageRoute(
                    builder: (_) => ClockPage(timetable: args.timetable),
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
                  return MaterialPageRoute(
                    builder: (_) => RecordDetailPage(arguments: args),
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
                    builder: (_) =>
                        SaveImagePage(examRecord: args.recordToSave),
                    settings: settings,
                  );
                case PurchasePage.routeName:
                  final args = settings.arguments as PurchasePageArguments;
                  return MaterialPageRoute(
                    builder: (_) => PurchasePage(
                      product: args.product,
                    ),
                    settings: settings,
                  );
                case ExamOverviewPage.routeName:
                  final args = settings.arguments as ExamOverviewPageArguments;
                  return MaterialPageRoute(
                    builder: (_) => ExamOverviewPage(
                      examDetail: args.examDetail,
                    ),
                    settings: settings,
                  );
              }
              return null;
            },
            theme: ThemeData(
              primarySwatch: indigoSwatch,
              fontFamily: 'NanumSquare',
              scaffoldBackgroundColor: SilgamApp.backgroundColor,
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
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
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
            builder: EasyLoading.init(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko'),
            ],
          );
        },
      ),
    );
  }

  void initialize() {
    FirebaseMessaging.instance.requestPermission();
    initializeDateFormatting('ko_KR');
    initializeEasyLoading();
  }
}

const MaterialColor indigoSwatch = MaterialColor(
  indigoPrimaryValue,
  <int, Color>{
    50: Color(0xFFE8EAF6),
    100: Color(0xFFC5CAE9),
    200: Color(0xFF9FA8DA),
    300: Color(0xFF7986CB),
    400: Color(0xFF5C6BC0),
    500: Color(0xFF3F51B5),
    600: Color(0xFF3949AB),
    700: Color(0xFF303F9F),
    800: Color(indigoPrimaryValue),
    900: Color(0xFF1A237E),
  },
);
const int indigoPrimaryValue = 0xFF283593;

const SystemUiOverlayStyle defaultSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.dark,
  statusBarColor: Colors.transparent,
  statusBarBrightness: Brightness.light,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.white,
);

const SystemUiOverlayStyle darkSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  statusBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarColor: Color(indigoPrimaryValue),
);
