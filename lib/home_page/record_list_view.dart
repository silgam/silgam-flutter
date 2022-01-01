import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/exam_record.dart';
import '../model/subject.dart';
import '../record_detail_page/record_detail_page.dart';
import '../repository/exam_record_repository.dart';
import '../util/material_hero.dart';
import '../util/scaffold_body.dart';

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
            return _RecordTile(record: _records[index]);
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

class _RecordTile extends StatefulWidget {
  final ExamRecord record;

  const _RecordTile({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  State<_RecordTile> createState() => _RecordTileState();
}

class _RecordTileState extends State<_RecordTile> {
  late ExamRecord _record;
  final ExamRecordRepository _recordRepository = ExamRecordRepository();

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.grey.shade200),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              child: Container(
                width: 1.5,
                color: Color(_record.getGradeColor()),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onTileTap,
              splashColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaterialHero(
                tag: 'time ${_record.hashCode}',
                child: Text(
                  DateFormat.yMEd('ko_KR').add_Hm().format(_record.examStartedTime),
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: MaterialHero(
                      tag: 'title ${_record.hashCode}',
                      child: Text(
                        _record.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  MaterialHero(
                    tag: 'subject ${_record.hashCode}',
                    child: Text(
                      _record.subject.subjectName,
                      style: TextStyle(
                        color: Color(_record.subject.firstColor),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (_record.feedback.isNotEmpty) const SizedBox(height: 6),
              if (_record.feedback.isNotEmpty)
                Text(
                  _record.feedback,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                  ),
                )
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildScoreGradeWidget(),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildScoreGradeWidget() {
    int? score = _record.score;
    int? grade = _record.grade;

    final List<TextSpan> textSpans = [];
    TextStyle smallTextStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey.shade700,
    );

    if (score != null) {
      textSpans.add(TextSpan(text: score.toString()));
      textSpans.add(
        TextSpan(
          text: ' 점',
          style: smallTextStyle,
        ),
      );
    }
    if (score != null && grade != null) {
      textSpans.add(const TextSpan(text: '\n'));
    }
    if (grade != null) {
      textSpans.add(TextSpan(text: grade.toString()));
      textSpans.add(
        TextSpan(
          text: ' 등급',
          style: smallTextStyle,
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.end,
      text: TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 18,
          height: 1.2,
          color: Colors.black,
          fontFamily: 'NotoSansKR',
        ),
        children: textSpans,
      ),
    );
  }

  void _onTileTap() async {
    final args = RecordDetailPageArguments(record: _record);
    await Navigator.pushNamed(context, RecordDetailPage.routeName, arguments: args);
    _refresh();
  }

  void _refresh() async {
    _record = await _recordRepository.getExamRecordById(_record.documentId);
    setState(() {});
  }
}

enum RecordListViewEvent { refresh }
