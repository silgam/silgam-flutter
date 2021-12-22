import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/exam_record.dart';
import '../model/subject.dart';
import '../record_detail_page/record_detail_page.dart';
import '../repository/exam_record_repository.dart';
import '../util/scaffold_body.dart';

class RecordView extends StatefulWidget {
  static const title = '기록';

  const RecordView({Key? key}) : super(key: key);

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  final ExamRecordRepository _recordRepository = ExamRecordRepository();
  List<ExamRecord> _records = [];
  bool _isFirstRefresh = true;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ScaffoldBody(
        title: RecordView.title,
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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTileTap,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 8, color: Colors.grey.shade100),
          ],
        ),
        // color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMEd('ko_KR').format(widget.record.examStartedTime),
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          widget.record.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.record.subject.subjectName,
                        style: TextStyle(
                          color: Color(widget.record.subject.firstColor),
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (widget.record.feedback.isNotEmpty) const SizedBox(height: 6),
                  if (widget.record.feedback.isNotEmpty)
                    Text(
                      widget.record.feedback,
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
            Text(
              _getScoreGradeText(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 16,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  void _onTileTap() {
    final args = RecordDetailPageArguments(record: widget.record);
    Navigator.pushNamed(context, RecordDetailPage.routeName, arguments: args);
  }

  String _getScoreGradeText() {
    int? score = widget.record.score;
    int? grade = widget.record.grade;
    if (score != null && grade == null) return '$score점';
    if (score == null && grade != null) return '$grade등급';
    if (score != null && grade != null) return '$score점\n$grade등급';
    return '';
  }
}
