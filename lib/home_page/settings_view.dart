import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../repository/user_repository.dart';
import '../util/scaffold_body.dart';

class SettingsView extends StatefulWidget {
  static const title = '설정';

  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final User _user = UserRepository().getUser();

  @override
  Widget build(BuildContext context) {
    return ScaffoldBody(
      title: SettingsView.title,
      child: SliverList(
        delegate: SliverChildListDelegate([
          _buildLoginInfo(),
          const _Divider(),
          _SettingTile(
            onTap: () {},
            title: '로그아웃',
          ),
          const _Divider(),
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
    String providerIconPath = '';
    final String providerId = _user.providerData.first.providerId;
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
              backgroundImage: NetworkImage(_user.photoURL ?? ''),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user.displayName ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _user.email ?? '',
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
}

class _SettingTile extends StatelessWidget {
  final GestureTapCallback? onTap;
  final String title;

  const _SettingTile({
    Key? key,
    this.onTap,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(title),
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
