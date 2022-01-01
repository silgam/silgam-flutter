import 'dart:async';

import 'package:flutter/material.dart';

import '../../model/exam_record.dart';
import '../../repository/exam_record_repository.dart';
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
  bool _isFirstRefresh = true;
  late final StreamSubscription _eventStreamSubscription;

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _eventStreamSubscription = widget.eventStream.listen((RecordListViewEvent event) {
      switch (event) {
        case RecordListViewEvent.refresh:
          _onRefresh();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ScaffoldBody(
        title: RecordListView.title,
        child: SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          sliver: _buildMainBody(),
        ),
      ),
    );
  }

  Widget _buildMainBody() {
    if (_records.isEmpty && _isFirstRefresh) {
      return SliverFillRemaining(
        child: Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (_records.isEmpty) {
      return SliverFillRemaining(
        child: Container(
          alignment: Alignment.center,
          child: const Text('오른쪽 아래 버튼을 눌러 모의고사를 기록해보세요!'),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return RecordTile(record: _records[index]);
          },
          childCount: _records.length,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    _records = await _recordRepository.getMyExamRecords();
    _isFirstRefresh = false;
    setState(() {});
  }

  @override
  void dispose() {
    _eventStreamSubscription.cancel();
    super.dispose();
  }
}

enum RecordListViewEvent { refresh }
