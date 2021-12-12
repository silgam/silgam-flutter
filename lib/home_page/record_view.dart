import 'package:flutter/material.dart';

import '../login_page/login_page.dart';
import '../util/scaffold_body.dart';

class RecordView extends StatelessWidget {
  static const title = '기록';

  const RecordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldBody(
      title: title,
      child: SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(20),
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, LoginPage.routeName);
            },
            child: const Text('로그인'),
          ),
        ),
      ),
    );
  }
}
