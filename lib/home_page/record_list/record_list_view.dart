import 'dart:async';

import 'package:flutter/material.dart';

import '../../login_page/login_page.dart';
import '../../model/exam_record.dart';
import '../../record_detail_page/record_detail_page.dart';
import '../../repository/exam_record_repository.dart';
import '../../repository/user_repository.dart';
import '../../util/login_button.dart';
import '../../util/scaffold_body.dart';
import 'record_tile.dart';

class RecordListView extends StatefulWidget {
  static const title = '기록';
  final Stream<RecordListViewEvent> eventStream;

  const RecordListView({
    Key? key,
    required this.eventStream,
  }) : super(key: key);

  @override
  State<RecordListView> createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  final ExamRecordRepository _recordRepository = ExamRecordRepository();
  List<ExamRecord> _records = [];
  bool _isRefreshing = false;
  late final StreamSubscription _eventStreamSubscription;

  bool get isNotSignedIn => UserRepository().isNotSignedIn();

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _eventStreamSubscription = widget.eventStream.listen(_onEventReceived);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBody(
      title: RecordListView.title,
      isRefreshing: _isRefreshing,
      onRefresh: isNotSignedIn ? null : _onRefresh,
      child: _buildMainBody(),
    );
  }

  Widget _buildMainBody() {
    if (isNotSignedIn) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: LoginButton(
            onTap: _onLoginTap,
            description: '로그인하면 모의고사를 기록할 수 있어요!',
          ),
        ),
      );
    } else if (_records.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: const Text('오른쪽 아래 버튼을 눌러 모의고사를 기록해보세요!'),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return RecordTile(
                record: _records[index],
                onTileTap: () => _onTileTap(index),
              );
            },
            childCount: _records.length,
          ),
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    if (isNotSignedIn) return;
    setState(() {
      _isRefreshing = true;
    });
    _records = await _recordRepository.getMyExamRecords();
    setState(() {
      _isRefreshing = false;
    });
  }

  void _onEventReceived(RecordListViewEvent event) {
    switch (event) {
      case RecordListViewEvent.refresh:
        _onRefresh();
        break;
      case RecordListViewEvent.refreshUser:
        _onRefresh();
        break;
    }
  }

  void _onLoginTap() async {
    await Navigator.pushNamed(context, LoginPage.routeName);
    _onRefresh();
  }

  void _onTileTap(int index) async {
    final args = RecordDetailPageArguments(record: _records[index]);
    await Navigator.pushNamed(context, RecordDetailPage.routeName, arguments: args);
    _onRefresh();
  }

  @override
  void dispose() {
    _eventStreamSubscription.cancel();
    super.dispose();
  }
}

enum RecordListViewEvent {
  refresh,
  refreshUser,
}
