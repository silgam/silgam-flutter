import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../model/ads.dart';
import '../../../model/timetable.dart';
import '../../../util/analytics_manager.dart';
import '../../../util/const.dart';
import '../../../util/duration_extension.dart';
import '../../../util/injection.dart';
import '../../app/app.dart';
import '../../app/cubit/app_cubit.dart';
import '../../app/cubit/iap_cubit.dart';
import '../../clock/clock_page.dart';
import '../../common/ad_tile.dart';
import '../../common/custom_card.dart';
import '../../common/dialog.dart';
import '../../custom_exam_guide/custom_exam_guide_page.dart';
import '../../custom_exam_list/custom_exam_list_page.dart';
import '../../edit_record/edit_record_page.dart';
import '../../login/login_page.dart';
import '../../noise_setting/noise_setting_page.dart';
import '../../offline/offline_guide_page.dart';
import '../../purchase/purchase_page.dart';
import '../cubit/home_cubit.dart';
import '../record_list/record_list_view.dart';
import 'cubit/main_cubit.dart';

part 'ads_card.dart';
part 'button_card.dart';
part 'd_days_card.dart';
part 'silgam_now_card.dart';
part 'timetable_start_card.dart';
part 'welcome_messages.dart';

class MainView extends StatefulWidget {
  static const title = '메인';

  const MainView({
    Key? key,
  }) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final _randomWelcomeMessage =
      _welcomeMessages[Random().nextInt(_welcomeMessages.length)];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider.value(
      value: getIt.get<MainCubit>(),
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) => previous.me != current.me,
        listener: (context, state) {
          context.read<MainCubit>().updateAds();
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                screenWidth > tabletScreenWidth
                    ? _buildTabletLayout()
                    : _buildMobileLayout(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final originalHorizontalPadding = screenWidth > 1000 ? 80.0 : 50.0;
    final horizontalPadding = max(
      (screenWidth - maxWidthForTablet) / 2,
      originalHorizontalPadding,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenWidth > 1000 ? 80 : 40),
        _buildTitle(horizontalPadding: horizontalPadding, isTablet: true),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeMessage(isTablet: true),
              const SizedBox(height: 8),
              const Divider(indent: 20, endIndent: 20),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAdsCard(),
                        _buildLoginCard(),
                        _buildCustomExamCard(),
                        _buildNoiseSettingCard(),
                        _buildRecordCard(),
                        _buildSendFeedbackCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: [
                        _buildDDaysCard(),
                        const _SilgamNowCard(),
                        _buildTimetableStartCard(),
                      ],
                    ),
                  )
                ],
              ),
              _buildAd(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = max((screenWidth - maxWidth) / 2, 20.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildTitle(horizontalPadding: horizontalPadding),
        const SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeMessage(),
              const SizedBox(height: 4),
              const Divider(indent: 20, endIndent: 20),
              _buildAdsCard(),
              _buildDDaysCard(),
              const _SilgamNowCard(),
              _buildTimetableStartCard(),
              _buildLoginCard(),
              _buildCustomExamCard(),
              _buildNoiseSettingCard(),
              _buildRecordCard(),
              _buildSendFeedbackCard(),
              _buildAd(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle({
    required double horizontalPadding,
    bool isTablet = false,
  }) {
    final DateTime today = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: horizontalPadding),
          child: Text(
            // cspell:disable-next-line
            DateFormat.MMMMEEEEd('ko_KR').format(today),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: isTablet ? 28 : 24,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: IntrinsicHeight(
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSnsButton(
                        snsName: "support",
                        tooltip: '카카오톡 채널로 문의하기',
                        url: urlSupport,
                      ),
                      _buildSnsButton(
                        snsName: "kakaotalk",
                        tooltip: '실감 오픈채팅방',
                        url: urlOpenchat,
                      ),
                      _buildSnsButton(
                        snsName: "instagram",
                        tooltip: '실감 인스타그램',
                        url: urlInstagram,
                      ),
                      SizedBox(width: horizontalPadding - 12),
                    ],
                  ),
                ),
                Container(
                  width: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SilgamApp.backgroundColor,
                        SilgamApp.backgroundColor.withAlpha(0)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSnsButton({
    required String snsName,
    required String tooltip,
    required String url,
  }) {
    return IconButton(
      onPressed: () {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        AnalyticsManager.logEvent(
          name: '[HomePage-main] SNS button tapped',
          properties: {'title': tooltip},
        );
      },
      splashRadius: 20,
      tooltip: tooltip,
      visualDensity: const VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: VisualDensity.minimumDensity,
      ),
      icon: SvgPicture.asset(
        'assets/sns_$snsName.svg',
        color: Colors.grey,
        width: 20,
      ),
    );
  }

  Widget _buildWelcomeMessage({bool isTablet = false}) {
    return Text(
      _randomWelcomeMessage,
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: isTablet ? 16 : 13,
      ),
    );
  }

  Widget _buildAdsCard() {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state.ads.isNotEmpty) {
          return AdsCard(ads: state.ads);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildDDaysCard() {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state.dDayItems.isNotEmpty) {
          return _DDaysCard(dDayItems: state.dDayItems);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildTimetableStartCard() {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          !listEquals(previous.getAllTimetables(), current.getAllTimetables()),
      builder: (context, state) {
        return _TimetableStartCard(timetables: state.getAllTimetables());
      },
    );
  }

  Widget _buildLoginCard() {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          previous.isSignedIn != current.isSignedIn,
      builder: (context, state) {
        if (state.isNotSignedIn) {
          return _ButtonCard(
            onTap: _onLoginButtonTap,
            iconData: Icons.login,
            title: '간편로그인하고 더 많은 기능 이용하기',
            primary: true,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildCustomExamCard() {
    return _ButtonCard(
      onTap: () {
        Navigator.pushNamed(context, CustomExamListPage.routeName);
      },
      iconData: Icons.palette,
      title: '나만의 과목 만들기',
    );
  }

  Widget _buildNoiseSettingCard() {
    return _ButtonCard(
      onTap: _onNoiseSettingButtonTap,
      iconData: Icons.graphic_eq,
      title: '백색 소음, 시험장 소음 설정하기',
    );
  }

  Widget _buildRecordCard() {
    return _ButtonCard(
      onTap: _onRecordButtonTap,
      iconData: Icons.edit,
      title: '모의고사 기록하고 피드백하기',
    );
  }

  Widget _buildSendFeedbackCard() {
    return _ButtonCard(
      onTap: _onSendFeedbackButtonTap,
      iconData: CupertinoIcons.paperplane_fill,
      title: '실감팀에게 의견 보내기',
    );
  }

  Widget _buildAd() {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          previous.productBenefit.isAdsRemoved !=
          current.productBenefit.isAdsRemoved,
      builder: (context, appState) {
        if (isAdmobDisabled || appState.productBenefit.isAdsRemoved) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return AdTile(
              width: constraints.maxWidth.toInt(),
              margin: const EdgeInsets.symmetric(vertical: 8),
            );
          },
        );
      },
    );
  }

  void _onLoginButtonTap() {
    Navigator.pushNamed(context, LoginPage.routeName);
  }

  void _onNoiseSettingButtonTap() {
    Navigator.pushNamed(context, NoiseSettingPage.routeName);
  }

  void _onRecordButtonTap() async {
    final isSignedIn = context.read<AppCubit>().state.isSignedIn;
    if (isSignedIn) {
      await Navigator.pushNamed(
        context,
        EditRecordPage.routeName,
        arguments: EditRecordPageArguments(),
      );
    }
    if (mounted) {
      context.read<HomeCubit>().changeTabByTitle(RecordListView.title);
    }
  }

  void _onSendFeedbackButtonTap() {
    showSendFeedbackDialog(context);
  }
}
