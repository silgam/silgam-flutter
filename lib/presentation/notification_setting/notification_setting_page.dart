import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ui/ui.dart';

import '../app/cubit/app_cubit.dart';
import '../common/dialog.dart';
import '../home/settings/settings_view.dart';

class NotificationSettingPage extends StatelessWidget {
  const NotificationSettingPage({super.key});

  static const routeName = '/notification_setting';

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '알림 설정',
      onBackPressed: () => Navigator.of(context).pop(),
      child: BlocConsumer<AppCubit, AppState>(
        listenWhen:
            (previous, current) =>
                previous.me?.isMarketingInfoReceivingConsented !=
                    current.me?.isMarketingInfoReceivingConsented ||
                previous.isOffline != current.isOffline,
        listener: (context, appState) {
          EasyLoading.dismiss();
        },
        builder: (context, appState) {
          final me = appState.me;

          if (me == null) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              _buildSwitchTile(
                title: '마케팅 정보 수신 동의',
                description: '실감의 상품 소개, 이벤트 등 유용한 정보들을 푸시알림으로 받아보실 수 있어요.',
                value: me.isMarketingInfoReceivingConsented ?? false,
                onChanged: (value) => _onMarketingInfoReceivingConsentChanged(context, value),
              ),
              const SettingDivider(),
            ],
          );
        },
      ),
    );
  }

  void _onMarketingInfoReceivingConsentChanged(BuildContext context, bool value) async {
    EasyLoading.show();
    await changeMarketingInfoReceivingConsentStatus(context, value);
  }

  Widget _buildSwitchTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
