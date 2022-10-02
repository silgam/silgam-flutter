import 'dart:async';

import 'package:flutter/material.dart';

import '../../../model/exam_record.dart';
import '../../../repository/exam_record_repository.dart';
import '../../../repository/user_repository.dart';
import '../../common/login_button.dart';
import '../../common/scaffold_body.dart';
import '../../login_page/login_page.dart';
import '../../record_detail_page/record_detail_page.dart';
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

  bool get _isSignedIn => UserRepository().isSignedIn();
  bool get _isNotSignedIn => UserRepository().isNotSignedIn();

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
      onRefresh: _isNotSignedIn ? null : _onRefresh,
      slivers: [
        if (_isNotSignedIn) _buildLoginButton(),
        if (_isSignedIn) _buildQuerySection(),
        if (_isSignedIn) _buildListSection(),
        if (_isSignedIn && _records.isEmpty) _buildDescription(),
      ],
    );
  }

  Widget _buildLoginButton() {
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
  }

  Widget _buildQuerySection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        color: Colors.red,
      ),
    );
  }

  Widget _buildListSection() {
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

  Widget _buildDescription() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text('오른쪽 아래 버튼을 눌러 모의고사를 기록해보세요!'),
      ),
    );
  }

  Future<void> _onRefresh() async {
    if (_isNotSignedIn) return;
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
