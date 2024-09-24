import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../util/analytics_manager.dart';
import '../../../util/const.dart';
import '../../../util/injection.dart';
import '../../app/app.dart';
import '../../app/cubit/app_cubit.dart';
import '../../common/ad_tile.dart';
import 'ads_card.dart';
import 'cubit/main_cubit.dart';
import 'd_days_card.dart';
import 'quick_launcher_card.dart';
import 'silgam_now_card.dart';
import 'timetable_start_card.dart';
import 'welcome_messages.dart';

class MainView extends StatefulWidget {
  static const title = '메인';

  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final _randomWelcomeMessage =
      welcomeMessages[Random().nextInt(welcomeMessages.length)];

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
        width: 20,
        colorFilter: const ColorFilter.mode(
          Colors.grey,
          BlendMode.srcIn,
        ),
      ),
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

  Widget _buildWelcomeMessage({bool isTablet = false}) {
    return Text(
      _randomWelcomeMessage,
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: isTablet ? 16 : 13,
      ),
    );
  }

  Widget _buildTimetableStartCard() {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          !listEquals(previous.getAllTimetables(), current.getAllTimetables()),
      builder: (context, state) {
        return TimetableStartCard(timetables: state.getAllTimetables());
      },
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AdsCard(),
                        QuickLauncherCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: [
                        const DDaysCard(),
                        const SilgamNowCard(),
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
              const AdsCard(),
              const DDaysCard(),
              const SilgamNowCard(),
              _buildTimetableStartCard(),
              const QuickLauncherCard(),
              _buildAd(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

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
}
