import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../app/cubit/app_cubit.dart';
import '../common/custom_menu_bar.dart';
import '../common/dialog.dart';
import '../home_page/settings/settings_view.dart';

class NotificationSettingPage extends StatelessWidget {
  const NotificationSettingPage({super.key});

  static const routeName = '/notification_setting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AppCubit, AppState>(
          listener: (context, appState) {
            EasyLoading.dismiss();
          },
          builder: (context, appState) {
            final me = appState.me;
            return Column(
              children: [
                const CustomMenuBar(title: '알림 설정'),
                if (me != null)
                  _buildSwitchTile(
                    title: '마케팅 정보 수신 동의',
                    description: '실감의 상품 소개, 이벤트 등 유용한 정보들을 푸시알림으로 받아보실 수 있어요.',
                    value: me.isMarketingInfoReceivingConsented ?? false,
                    onChanged: (value) =>
                        _onMarketingInfoReceivingConsentChanged(context, value),
                  ),
                if (me != null) const SettingDivider(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onMarketingInfoReceivingConsentChanged(
    BuildContext context,
    bool value,
  ) async {
    final previousValue =
        context.read<AppCubit>().state.me?.isMarketingInfoReceivingConsented;
    final result = await showMarketingInfoReceivingConsentDialog(
      context,
      isDismissible: true,
    );
    final isChanged = result != previousValue;
    if (result != null && isChanged) {
      EasyLoading.show();
    }
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
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
