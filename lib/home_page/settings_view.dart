import 'package:flutter/material.dart';

import '../util/scaffold_body.dart';

class SettingsView extends StatelessWidget {
  static const title = '설정';

  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldBody(
      title: title,
      child: SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(20),
          child: const Text(
            '설정 페이지가 업데이트될 예정입니다.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
