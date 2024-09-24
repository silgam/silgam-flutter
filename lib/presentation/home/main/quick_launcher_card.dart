import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/cubit/app_cubit.dart';
import '../../common/custom_card.dart';
import '../../common/dialog.dart';
import '../../custom_exam_list/custom_exam_list_page.dart';
import '../../edit_record/edit_record_page.dart';
import '../../login/login_page.dart';
import '../../noise_setting/noise_setting_page.dart';
import '../cubit/home_cubit.dart';
import '../record_list/record_list_view.dart';

class QuickLauncherCard extends StatefulWidget {
  const QuickLauncherCard({super.key});

  @override
  State<QuickLauncherCard> createState() => _QuickLauncherCardState();
}

class _QuickLauncherCardState extends State<QuickLauncherCard> {
  void _onLoginItemTap() {
    Navigator.pushNamed(context, LoginPage.routeName);
  }

  void _onCustomExamItemTap() {
    Navigator.pushNamed(context, CustomExamListPage.routeName);
  }

  void _onNoiseSettingItemTap() {
    Navigator.pushNamed(context, NoiseSettingPage.routeName);
  }

  void _onRecordItemTap() async {
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

  void _onSendFeedbackItemTap() {
    showSendFeedbackDialog(context);
  }

  Widget _buildItem({
    required IconData iconData,
    required String title,
    required GestureTapCallback onTap,
    bool primary = false,
  }) {
    final color = primary ? Theme.of(context).primaryColor : Colors.black;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) =>
            previous.isSignedIn != current.isSignedIn,
        builder: (context, state) {
          return GridView.extent(
            maxCrossAxisExtent: 110,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              if (state.isNotSignedIn)
                _buildItem(
                  onTap: _onLoginItemTap,
                  iconData: Icons.login,
                  title: '간편 가입\n및 로그인',
                  primary: true,
                ),
              _buildItem(
                onTap: _onCustomExamItemTap,
                iconData: Icons.palette,
                title: '나만의 과목\n만들기',
              ),
              _buildItem(
                onTap: _onNoiseSettingItemTap,
                iconData: Icons.graphic_eq,
                title: '시험장 소음\n설정하기',
              ),
              _buildItem(
                onTap: _onRecordItemTap,
                iconData: Icons.edit,
                title: '모의고사\n기록하기',
              ),
              _buildItem(
                onTap: _onSendFeedbackItemTap,
                iconData: CupertinoIcons.paperplane_fill,
                title: '실감팀에게\n의견 보내기',
              ),
            ],
          );
        },
      ),
    );
  }
}
