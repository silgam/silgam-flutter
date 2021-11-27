import 'package:flutter/material.dart';

class RecordView extends StatelessWidget {
  const RecordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20),
        child: const Text(
          '모의고사를 피드백하고 기록할 수 있는 기능이 업데이트될 예정입니다.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
