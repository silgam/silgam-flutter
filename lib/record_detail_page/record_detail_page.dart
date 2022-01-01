import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../edit_record_page/edit_record_page.dart';
import '../model/exam_record.dart';
import '../model/problem.dart';
import '../model/subject.dart';
import '../repository/exam_record_repository.dart';
import '../review_problem_detail_page/review_problem_detail_page.dart';
import '../util/material_hero.dart';
import '../util/review_problem_card.dart';

class RecordDetailPage extends StatefulWidget {
  static const routeName = '/record_detail';
  final RecordDetailPageArguments arguments;

  const RecordDetailPage({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late ExamRecord _record;
  final ExamRecordRepository _recordRepository = ExamRecordRepository();

  @override
  void initState() {
    super.initState();
    _record = widget.arguments.record;
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: defaultSystemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildMenuBar(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildContent(),
                        ),
                      ),
                    ),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white.withAlpha(0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Material(
            type: MaterialType.transparency,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              splashRadius: 20,
            ),
          ),
          const Expanded(child: SizedBox.shrink()),
          Material(
            type: MaterialType.transparency,
            child: IconButton(
              onPressed: _onEditButtonPressed,
              icon: const Icon(Icons.edit),
              splashRadius: 20,
              tooltip: '수정',
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete),
              splashRadius: 20,
              tooltip: '삭제',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 0.7,
                color: Color(_record.getGradeColor()),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: _buildTitle(),
              ),
            ],
          ),
        ),
        if (_record.score != null || _record.grade != null || _record.examDurationMinutes != null)
          Column(
            children: [
              const SizedBox(height: 32),
              _buildScoreBoard(),
              const SizedBox(height: 8),
            ],
          ),
        if (_record.wrongProblems.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSubTitle('틀린 문제'),
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children: [
                  for (final wrongProblem in _record.wrongProblems)
                    Chip(
                      label: Text('${wrongProblem.problemNumber}번'),
                      backgroundColor: Theme.of(context).primaryColor,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        height: 1.21,
                      ),
                    ),
                ],
              ),
            ],
          ),
        if (_record.feedback.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSubTitle('피드백'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_record.feedback),
              ),
            ],
          ),
        if (_record.reviewProblems.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSubTitle('복습할 문제'),
              const SizedBox(height: 8),
              GridView.extent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final problem in _record.reviewProblems)
                    ReviewProblemCard(
                      problem: problem,
                      onTap: () => _onReviewProblemCardTap(problem),
                    ),
                ],
              )
            ],
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
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
        Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: MaterialHero(
                  tag: 'title ${_record.hashCode}',
                  child: Text(
                    _record.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
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
        ),
      ],
    );
  }

  Widget _buildScoreBoard() {
    int? score = _record.score;
    int? grade = _record.grade;
    int? examDurationMinutes = _record.examDurationMinutes;

    final List<Widget> scoreItems = [
      if (score != null) _buildScoreItem('점수', score),
      if (grade != null) _buildScoreItem('등급', grade),
      if (examDurationMinutes != null) _buildScoreItem('시험 시간', examDurationMinutes),
    ];

    const divider = VerticalDivider(indent: 6, endIndent: 6);
    if (scoreItems.length == 3) {
      scoreItems.insert(2, divider);
      scoreItems.insert(1, divider);
    }
    if (scoreItems.length == 2) {
      scoreItems.insert(1, divider);
    }

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: scoreItems,
      ),
    );
  }

  Widget _buildScoreItem(String title, int value) {
    return Column(
      children: [
        _buildSubTitle(title),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  void _refresh() async {
    _record = await _recordRepository.getExamRecordById(_record.documentId);
    setState(() {});
  }

  void _onEditButtonPressed() async {
    final arguments = EditRecordPageArguments(recordToEdit: _record);
    await Navigator.pushNamed(context, EditRecordPage.routeName, arguments: arguments);
    _refresh();
  }

  void _onReviewProblemCardTap(ReviewProblem problem) {
    final arguments = ReviewProblemDetailPageArguments(problem: problem);
    Navigator.pushNamed(context, ReviewProblemDetailPage.routeName, arguments: arguments);
  }
}

class RecordDetailPageArguments {
  final ExamRecord record;

  RecordDetailPageArguments({required this.record});
}
