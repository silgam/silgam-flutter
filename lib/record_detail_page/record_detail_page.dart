import 'package:flutter/material.dart';

import '../model/exam_record.dart';

class RecordDetailPage extends StatelessWidget {
  static const routeName = '/record_detail';
  final RecordDetailPageArguments arguments;

  const RecordDetailPage({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}

class RecordDetailPageArguments {
  final ExamRecord record;

  RecordDetailPageArguments({required this.record});
}
