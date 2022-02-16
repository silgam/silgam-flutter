import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../clock_page/clock_page.dart';
import '../../edit_record_page/edit_record_page.dart';
import '../../login_page/login_page.dart';
import '../../model/exam.dart';
import '../../repository/dday_repository.dart';
import '../../repository/exam_repository.dart';
import '../../repository/user_repository.dart';

part 'button_card.dart';

part 'card.dart';

part 'd_days_card.dart';

part 'exam_start_card.dart';

class MainView extends StatefulWidget {
  static const title = '메인';
  final Function() navigateToRecordTab;

  const MainView({
    Key? key,
    required this.navigateToRecordTab,
  }) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final DateTime today = DateTime.now();
  late final List<DDayItem> dDayItems = DDayRepository().getItemsToShow(today);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            _DDaysCard(dDayItems: dDayItems),
            _ExamStartCard(navigateToRecordTab: widget.navigateToRecordTab),
            if (UserRepository().isNotSignedIn())
              _ButtonCard(
                onTap: _onLoginButtonTap,
                iconData: Icons.login,
                title: '간편로그인하고 더 많은 기능 이용하기',
                primary: true,
              ),
            // _ButtonCard(
            //   onTap: () {},
            //   iconData: Icons.graphic_eq,
            //   title: '백색 소음, 시험장 소음 설정하기',
            // ),
            _ButtonCard(
              onTap: _onRecordButtonTap,
              iconData: Icons.edit,
              title: '모의고사 기록하고 피드백하기',
            ),
          ],
        ),
      ),
    );
  }

  void _onLoginButtonTap() {
    Navigator.pushNamed(context, LoginPage.routeName);
  }

  void _onRecordButtonTap() async {
    if (UserRepository().isSignedIn()) {
      await Navigator.pushNamed(context, EditRecordPage.routeName, arguments: EditRecordPageArguments());
    }
    widget.navigateToRecordTab();
  }
}
