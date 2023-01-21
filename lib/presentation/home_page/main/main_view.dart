import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/ads.dart';
import '../../../model/exam.dart';
import '../../../repository/ads/ads_repository.dart';
import '../../../repository/dday_repository.dart';
import '../../../repository/exam_repository.dart';
import '../../../util/analytics_manager.dart';
import '../../../util/const.dart';
import '../../../util/injection.dart';
import '../../app/app.dart';
import '../../app/cubit/app_cubit.dart';
import '../../clock_page/clock_page.dart';
import '../../common/ad_tile.dart';
import '../../edit_record_page/edit_record_page.dart';
import '../../login_page/login_page.dart';
import '../cubit/home_cubit.dart';
import '../record_list/record_list_view.dart';
import '../settings/noise_setting_page.dart';

part 'ads_card.dart';
part 'button_card.dart';
part 'card.dart';
part 'd_days_card.dart';
part 'exam_start_card.dart';
part 'welcome_messages.dart';

const double maxWidth = 500;

class MainView extends StatefulWidget {
  static const title = '메인';

  const MainView({
    Key? key,
  }) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final DDayRepository _dDayRepository = getIt.get();
  final AdsRepository _adsRepository = getIt.get();
  final DateTime today = DateTime.now();
  late final List<DDayItem> dDayItems = _dDayRepository.getItemsToShow(today);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _welcomeMessages[Random().nextInt(_welcomeMessages.length)],
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(indent: 20, endIndent: 20),
              FutureBuilder(
                future: _adsRepository.getAllAds(),
                builder: (_, AsyncSnapshot<Result> snapshot) {
                  final List<Ads> data = snapshot.data?.tryGetSuccess() ?? [];
                  if (data.isNotEmpty) {
                    return AdsCard(ads: data);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              if (dDayItems.isNotEmpty) _DDaysCard(dDayItems: dDayItems),
              const _ExamStartCard(),
              BlocBuilder<AppCubit, AppState>(
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
              ),
              _ButtonCard(
                onTap: _onNoiseSettingButtonTap,
                iconData: Icons.graphic_eq,
                title: '백색 소음, 시험장 소음 설정하기',
              ),
              _ButtonCard(
                onTap: _onRecordButtonTap,
                iconData: Icons.edit,
                title: '모의고사 기록하고 피드백하기',
              ),
              if (isAdsEnabled)
                AdTile(
                  width: MediaQuery.of(context)
                          .size
                          .width
                          .clamp(0, maxWidth)
                          .truncate() -
                      40,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            DateFormat.MMMMEEEEd('ko_KR').format(today),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: IntrinsicHeight(
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSnsButton(
                          snsName: "kakaotalk",
                          tooltip: '카카오톡으로 문의하기',
                          url: urlKakaotalk),
                      _buildSnsButton(
                          snsName: "instagram",
                          tooltip: '실감 인스타그램',
                          url: urlInstagram),
                      _buildSnsButton(
                          snsName: "facebook",
                          tooltip: '실감 페이스북',
                          url: urlFacebook),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                Container(
                  width: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade50,
                        Colors.grey.shade50.withAlpha(0)
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

  Widget _buildSnsButton(
      {required String snsName, required String tooltip, required String url}) {
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
}
