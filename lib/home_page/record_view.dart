import 'package:flutter/material.dart';

import '../model/exam_record.dart';
import '../repository/exam_record_repository.dart';
import '../util/scaffold_body.dart';

class RecordView extends StatefulWidget {
  static const title = '기록';

  const RecordView({Key? key}) : super(key: key);

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> with AutomaticKeepAliveClientMixin {
  final ExamRecordRepository _recordRepository = ExamRecordRepository();
  List<ExamRecord>? _records;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ScaffoldBody(
        title: RecordView.title,
        child: _buildMainBody(),
      ),
    );
  }

  Widget _buildMainBody() {
    if (_records == null) {
      return SliverFillRemaining(
        child: Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (_records?.isEmpty == true) {
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
            return Text(_records.toString());
          },
          childCount: 1,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    _records = await _recordRepository.getMyExamRecords();
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
