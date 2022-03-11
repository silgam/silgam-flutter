import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app.dart';
import '../../login_page/login_page.dart';
import '../../repository/user_repository.dart';
import '../../util/login_button.dart';
import '../../util/scaffold_body.dart';
import '../../util/shared_preferences_holder.dart';
import 'setting_tile.dart';

class SettingsView extends StatefulWidget {
  static const title = '설정';
  final Stream<SettingsViewEvent> eventStream;

  const SettingsView({
    Key? key,
    required this.eventStream,
  }) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  User? _user;
  late final StreamSubscription _eventStreamSubscription;

  @override
  void initState() {
    super.initState();
    _refreshUser();
    _eventStreamSubscription = widget.eventStream.listen(_onEventReceived);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBody(
      title: SettingsView.title,
      child: SliverList(
        delegate: SliverChildListDelegate([
          _user == null
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: LoginButton(onTap: _onLoginTap),
                )
              : _buildLoginInfo(),
          const _Divider(),
          // SettingTile(
          //   onTap: _onNoiseSettingButtonTap,
          //   title: '백색 소음, 시험장 소음 설정',
          //   description: '시험을 볼 때 백색소음과 시험장 소음을 통해 현장감을 극대화할 수 있습니다.',
          // ),
          // const _Divider(),
          const SettingTile(
            title: '시험 종료 후 바로 기록하기',
            description: '시험이 끝난 후에 모의고사를 기록할 수 있는 화면으로 넘어갑니다.',
            disabledDescription: '시험이 끝난 후에 모의고사 목록 화면으로 넘어갑니다.',
            preferenceKey: PreferenceKey.showAddRecordPageAfterExamFinished,
          ),
          const _Divider(thick: true),
          SettingTile(
            onTap: _onWriteReviewButtonTap,
            title: '리뷰 쓰기',
            description: '리뷰는 실감 팀에게 큰 도움이 됩니다.',
          ),
          const _Divider(),
          SettingTile(
            onTap: _onGoFacebookMessengerButtonTap,
            title: '개발자와 대화하기',
            description: '페이스북 메신저로 실감 팀에게 의견을 보내거나 문의할 수 있습니다.',
          ),
          const _Divider(),
          SettingTile(
            onTap: _onGoInstagramButtonTap,
            title: '실감 인스타그램 보러 가기',
            description: '팔로우하시면 실감의 새로운 소식을 빠르게 만나볼 수 있습니다.',
          ),
          const _Divider(),
          SettingTile(
            onTap: _onGoFacebookPageButtonTap,
            title: '실감 페이스북 페이지 보러 가기',
            description: '팔로우하시면 실감의 새로운 소식을 빠르게 만나볼 수 있습니다.',
          ),
          const _Divider(),
          if (_user != null)
            SettingTile(
              onTap: _onLogoutTap,
              title: '로그아웃',
            ),
          if (_user != null) const _Divider(),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        ]),
      ),
    );
  }

  Widget _buildLoginInfo() {
    final User? user = _user;
    if (user == null) throw Exception('User is null.');
    final String providerIconPath = getProviderIconPath(user);

    return GestureDetector(
      onLongPress: () => _onLoginLongPress(user),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardCornerRadius),
          color: Colors.grey.shade200,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL ?? 'https://via.placeholder.com/150?text=ㅇ'),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '이메일 없음',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: double.infinity,
                alignment: Alignment.bottomCenter,
                child: SvgPicture.asset(
                  providerIconPath,
                  height: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshUser() {
    setState(() {
      _user = UserRepository().getUserOrNull();
    });
  }

  void _onEventReceived(SettingsViewEvent event) {
    switch (event) {
      case SettingsViewEvent.refreshUser:
        _refreshUser();
        break;
    }
  }

  void _onLoginTap() async {
    await Navigator.pushNamed(context, LoginPage.routeName);
    _refreshUser();
  }

  void _onLoginLongPress(User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: SelectableText(user.uid),
      ),
    );
  }

  void _onLogoutTap() async {
    showDialog(
      context: context,
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
            style: TextButton.styleFrom(primary: Colors.grey),
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              _refreshUser();
              Navigator.pop(context);
            },
            child: const Text('로그아웃'),
          )
        ],
      ),
    );
  }

  // void _onNoiseSettingButtonTap() {
  //   Navigator.pushNamed(context, NoiseSettingPage.routeName);
  // }

  void _onWriteReviewButtonTap() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(appStoreId: '1598576852');
    }
  }

  void _onGoInstagramButtonTap() {
    launch('https://www.instagram.com/silgam.app');
  }

  void _onGoFacebookPageButtonTap() {
    launch('https://fb.me/SilgamOfficial');
  }

  void _onGoFacebookMessengerButtonTap() {
    launch('https://m.me/SilgamOfficial');
  }

  @override
  void dispose() {
    _eventStreamSubscription.cancel();
    super.dispose();
  }

  String getProviderIconPath(User user) {
    String providerId = '';
    if (user.providerData.isNotEmpty) {
      providerId = user.providerData.first.providerId;
    } else if (user.uid.startsWith('kakao')) {
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

class _Divider extends StatelessWidget {
  final bool thick;

  const _Divider({
    Key? key,
    this.thick = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double thickness = 0.5;
    double indent = 12;
    if (thick) {
      thickness = 1;
      indent = 0;
    }
    return Divider(
      color: Colors.grey.shade200,
      height: thickness,
      thickness: thickness,
      indent: indent,
      endIndent: indent,
    );
  }
}

enum SettingsViewEvent {
  refreshUser,
}
