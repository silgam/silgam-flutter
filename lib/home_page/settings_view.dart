import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../login_page/login_page.dart';
import '../repository/user_repository.dart';
import '../util/login_button.dart';
import '../util/scaffold_body.dart';

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
          _SettingTile(
            onTap: _onWriteReviewButtonTap,
            title: '리뷰 쓰기',
            description: '리뷰는 실감 팀에게 큰 도움이 됩니다.',
          ),
          const _Divider(),
          _SettingTile(
            onTap: _onGoFacebookPageButtonTap,
            title: '실감 페이스북 페이지 보러 가기',
            description: '좋아요 눌러주세요!',
          ),
          const _Divider(),
          _SettingTile(
            onTap: _onGoFacebookMessengerButtonTap,
            title: '개발자와 대화하기',
            description: '페이스북 메신저로 실감 팀에게 의견을 보내거나 문의할 수 있습니다.',
          ),
          const _Divider(),
          if (_user != null)
            _SettingTile(
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
    String providerIconPath = '';
    final String providerId = user.providerData.first.providerId;
    if (providerId.contains('google')) {
      providerIconPath = 'assets/google_icon.svg';
    } else if (providerId.contains('facebook')) {
      providerIconPath = 'assets/facebook_icon.svg';
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ''),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const Expanded(child: SizedBox.shrink()),
            Container(
              height: double.infinity,
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                providerIconPath,
                width: 28,
              ),
            ),
          ],
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

  void _onLogoutTap() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('로그아웃하실 건가요?'),
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

  void _onWriteReviewButtonTap() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(appStoreId: '1598576852');
    }
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
}

class _SettingTile extends StatelessWidget {
  final GestureTapCallback? onTap;
  final String title;
  final String? description;

  const _SettingTile({
    Key? key,
    this.onTap,
    required this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: description == null ? 16 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (description != null)
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 0.3, thickness: 0.3);
  }
}

enum SettingsViewEvent {
  refreshUser,
}
