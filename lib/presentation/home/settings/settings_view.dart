import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/user.dart';
import '../../../util/analytics_manager.dart';
import '../../../util/const.dart';
import '../../../util/injection.dart';
import '../../announcement_setting/announcement_setting_page.dart';
import '../../app/cubit/app_cubit.dart';
import '../../common/ad_tile.dart';
import '../../common/custom_card.dart';
import '../../common/dialog.dart';
import '../../common/login_button.dart';
import '../../common/purchase_button.dart';
import '../../common/scaffold_body.dart';
import '../../common/subtitle.dart';
import '../../custom_exam_list/custom_exam_list_page.dart';
import '../../customize_subject_name/customize_subject_name_page.dart';
import '../../login/login_page.dart';
import '../../my/my_page.dart';
import '../../noise_setting/noise_setting_page.dart';
import '../../notification_setting/notification_setting_page.dart';
import '../../offline/offline_guide_page.dart';
import 'setting_tile.dart';

class SettingsView extends StatefulWidget {
  static const title = '설정';
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final AppCubit _appCubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return ScaffoldBody(
          title: SettingsView.title,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                _buildSettingTiles(state),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSettingTiles(AppState appState) {
    return [
      const SizedBox(height: 8),
      appState.isSignedIn
          ? _buildLoginInfo(appState.me!)
          : LoginButton(onTap: _onLoginTap),
      if (appState.me?.isPurchasedUser != true)
        buildPurchaseButtonOr(
          margin: const EdgeInsets.symmetric(vertical: 16),
        ),
      if (appState.me?.isPurchasedUser == true) const SizedBox(height: 16),
      if (!isAdmobDisabled && !appState.productBenefit.isAdsRemoved)
        LayoutBuilder(
          builder: (context, constraints) {
            return AdTile(
              width: constraints.maxWidth.toInt(),
              margin: const EdgeInsets.only(bottom: 16),
            );
          },
        ),
      const Subtitle(text: '기본 설정', margin: EdgeInsets.zero),
      // TODO 로그인 확인
      const SettingTile(
        title: '시험 종료 후 자동 저장',
        description:
            '시험 종료 후 응시 기록과 랩타임 기록이 자동으로 저장돼요. (여러 과목을 응시할 경우 모든 과목이 저장됨)',
        preferenceKey: PreferenceKey.useAutoSaveRecords,
      ),
      appState.productBenefit.isLapTimeAvailable
          ? const SettingTile(
              title: '랩타임 기능 사용',
              description: '시험 중 랩타임 측정을 통해 시간 분배를 확인하고 모의고사 기록에 추가할 수 있어요.',
              preferenceKey: PreferenceKey.useLapTime,
            )
          : SettingTile(
              onTap: _onLapTimeSettingButtonTap,
              title: '랩타임 기능 사용',
              description: '시험 중 랩타임 측정을 통해 시간 분배를 확인하고 모의고사 기록에 추가할 수 있어요.',
              showArrow: true,
            ),
      const SettingDivider(),
      SettingTile(
        onTap: _onCustomizeSubjectNameButtonTap,
        title: '기본 과목 이름 설정',
        description: '국어, 수학, 탐구 등 기본 과목의 이름을 바꿀 수 있어요.',
        showArrow: true,
      ),
      const SettingDivider(),
      SettingTile(
        onTap: _onCustomExamButtonTap,
        title: '나만의 과목 만들기',
        description:
            '기본 과목의 이름, 응시 시간 등을 바꾼 새로운 과목을 만들 수 있어요. (하프 모의고사, 내신 시험 등 커스텀 가능)',
        showArrow: true,
      ),
      const Subtitle(text: '소리 설정', margin: EdgeInsets.zero),
      SettingTile(
        onTap: _onNoiseSettingButtonTap,
        title: '백색 소음, 시험장 소음 설정',
        description: '시험을 볼 때 백색소음과 시험장 소음을 통해 현장감을 극대화할 수 있어요.',
        showArrow: true,
      ),
      const SettingDivider(),
      SettingTile(
        onTap: _onAnnouncementSettingButtonTap,
        title: '타종 소리 설정',
        description: '시험 중 재생되는 타종 소리의 종류를 선택할 수 있어요.',
        showArrow: true,
      ),
      const Subtitle(text: '기타', margin: EdgeInsets.zero),
      SettingTile(
        onTap: _onOfflineGuideButtonTap,
        title: '오프라인 모드 이용 안내',
        description: '인터넷이 없는 환경에서도 이용할 수 있는 기능들에 대해 알아보세요.',
      ),
      const SettingDivider(),
      if (appState.isSignedIn)
        SettingTile(
          onTap: _onNotificationSettingButtonTap,
          title: '알림 설정',
        ),
      if (appState.isSignedIn) const SettingDivider(),
      SettingTile(
        onTap: _onWriteReviewButtonTap,
        title: '리뷰 쓰기',
        description: '리뷰는 실감 팀에게 큰 도움이 돼요.',
      ),
      const SettingDivider(),
      SettingTile(
        onTap: _onSendFeedbackButtonTap,
        title: '실감팀에게 의견 보내기',
        description: '실감팀에게 전달하고 싶은 의견을 무엇이든 앱 안에서 바로 보낼 수 있어요.',
      ),
      const SettingDivider(),
      SettingTile(
        onTap: () => launchUrl(Uri.parse(urlSupport),
            mode: LaunchMode.externalApplication),
        title: '카카오톡 채널로 문의하기',
        description: '앱 사용 중 발생하는 오류나 의견 등 실감팀의 답변이 필요한 내용을 문의할 수 있어요.',
      ),
      if (appState.isSignedIn) const SettingDivider(),
      if (appState.isSignedIn)
        SettingTile(
          onTap: _onLogoutTap,
          title: '로그아웃',
        ),
      if (appState.isSignedIn) const SettingDivider(),
      if (appState.isSignedIn)
        SettingTile(
          onTap: () => _onDeleteAccountTap(), // 유저 삭제, 로그아웃
          title: '계정 탈퇴',
          titleColor: Colors.red,
        ),
      const Divider(),
      const SizedBox(height: 8),
      FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              '버전 정보 ${snapshot.data?.version}+${snapshot.data?.buildNumber}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () {
          launchUrl(
            Uri.parse(urlPrivacy),
            mode: LaunchMode.externalApplication,
          );
        },
        child: const Text(
          '개인정보처리방침',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () {
          launchUrl(
            Uri.parse(urlTerms),
            mode: LaunchMode.externalApplication,
          );
        },
        child: const Text(
          '서비스이용약관',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/licenses'),
              builder: (_) => const LicensePage(),
            ),
          );
        },
        child: const Text(
          '오픈소스 라이선스',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 40),
    ];
  }

  Widget _buildLoginInfo(User user) {
    final String providerIconPath = getProviderIconPath(user);
    return CustomCard(
      child: InkWell(
        onTap: () => _onLoginInfoTap(),
        onLongPress: () => _onLoginInfoLongPress(user),
        splashColor: Colors.transparent,
        highlightColor: Colors.grey.withAlpha(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: IntrinsicHeight(
            child: Row(
              children: [
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    user.photoUrl ?? '',
                  ),
                  backgroundColor: Colors.grey,
                  radius: 24,
                  onBackgroundImageError: (exception, stackTrace) {},
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName ?? '이름 없음',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            providerIconPath,
                            height: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email ?? '이메일 없음',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const VerticalDivider(
                  indent: 8,
                  endIndent: 8,
                  width: 1,
                ),
                const SizedBox(width: 4),
                CachedNetworkImage(
                  imageUrl: user.isProductTrial
                      ? user.activeProduct.trialStampImageUrl
                      : user.activeProduct.stampImageUrl,
                  height: 74,
                  errorWidget: (_, __, ___) =>
                      const AspectRatio(aspectRatio: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLoginTap() async {
    await Navigator.pushNamed(context, LoginPage.routeName);
  }

  void _onLoginInfoTap() {
    AnalyticsManager.logEvent(name: '[HomePage-settings] Login info tapped');
    Navigator.pushNamed(context, MyPage.routeName);
  }

  void _onLoginInfoLongPress(User user) {
    AnalyticsManager.logEvent(
      name: '[HomePage-settings] Login info long pressed',
    );
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'view_user_id_dialog'),
      builder: (_) => AlertDialog(
        content: SelectableText(
          user.id,
          onTap: () {
            AnalyticsManager.logEvent(
                name: '[HomePage-settings] User ID copied');
            Clipboard.setData(ClipboardData(text: user.id));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('복사되었습니다.'),
              ),
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _onLogoutTap() async {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사용할 수 없는 기능이에요.',
        dismissOnTap: true,
      );
      return;
    }

    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'logout_confirm_dialog'),
      builder: (_) => AlertDialog(
        title: const Text(
          '로그아웃하실 건가요?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              await getIt<AppCubit>().onLogout();
              if (mounted) Navigator.pop(context);
              await AnalyticsManager.logEvent(
                  name: '[HomePage-settings] Logout');
            },
            child: const Text('로그아웃'),
          )
        ],
      ),
    );
  }

  void _onDeleteAccountTap() async {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사용할 수 없는 기능이에요.',
        dismissOnTap: true,
      );
      return;
    }

    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'account_delete_confirm_dialog'),
      builder: (_) => AlertDialog(
        title: const Text(
          '탈퇴하시겠습니까?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('탈퇴하면 모든 데이터가 삭제되고 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                await _appCubit.onLogout();
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login') {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 7),
                        content: Text(
                            '로그인한 지 오래되어 탈퇴할 수 없습니다. 탈퇴하려던 계정으로 다시 로그인해주세요.'),
                      ),
                    );
                    Navigator.pushNamed(context, LoginPage.routeName);
                  }
                }
              }
              await AnalyticsManager.logEvent(
                  name: '[HomePage-settings] Delete account');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('계정 탈퇴'),
          )
        ],
      ),
    );
  }

  void _onLapTimeSettingButtonTap() {
    showLapTimeLimitInfoDialog(context);
  }

  void _onNoiseSettingButtonTap() {
    Navigator.pushNamed(context, NoiseSettingPage.routeName);
  }

  void _onAnnouncementSettingButtonTap() {
    Navigator.pushNamed(context, AnnouncementSettingPage.routeName);
  }

  void _onCustomizeSubjectNameButtonTap() {
    Navigator.pushNamed(context, CustomizeSubjectNamePage.routeName);
  }

  void _onCustomExamButtonTap() {
    Navigator.pushNamed(context, CustomExamListPage.routeName);
  }

  void _onOfflineGuideButtonTap() {
    Navigator.pushNamed(context, OfflineGuidePage.routeName);
  }

  void _onNotificationSettingButtonTap() {
    Navigator.pushNamed(context, NotificationSettingPage.routeName);
  }

  void _onWriteReviewButtonTap() async {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사용할 수 없는 기능이에요.',
        dismissOnTap: true,
      );
      return;
    }

    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(appStoreId: '1598576852');
    }
  }

  void _onSendFeedbackButtonTap() {
    showSendFeedbackDialog(context);
  }

  String getProviderIconPath(User user) {
    String providerId = '';
    if (user.providerDatas.isNotEmpty) {
      providerId = user.providerDatas.first.providerId;
    } else if (user.id.startsWith('kakao')) {
      providerId = 'kakao.com';
    }
    String providerIconPath = '';
    if (providerId.contains('google')) {
      providerIconPath = 'assets/google_icon.svg';
    } else if (providerId.contains('facebook')) {
      providerIconPath = 'assets/facebook_icon.svg';
    } else if (providerId.contains('apple')) {
      providerIconPath = 'assets/apple_icon.svg';
    } else if (providerId.contains('kakao')) {
      providerIconPath = 'assets/kakao_icon_with_text.svg';
    }
    return providerIconPath;
  }
}

class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.black.withOpacity(0.06),
      height: 0.5,
      thickness: 0.5,
      indent: 20,
      endIndent: 20,
    );
  }
}
