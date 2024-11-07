import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

import '../../model/exam_record.dart';
import '../../model/problem.dart';
import '../../repository/exam_record/exam_record_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/const.dart';
import '../../util/injection.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../common/ad_tile.dart';
import '../common/custom_menu_bar.dart';
import '../common/progress_overlay.dart';
import '../common/review_problem_card.dart';
import '../edit_record/edit_record_page.dart';
import '../home/record_list/cubit/record_list_cubit.dart';
import '../review_problem_detail/review_problem_detail_page.dart';
import '../save_image/save_image_page.dart';

class RecordDetailPage extends StatefulWidget {
  static const routeName = '/record_detail';
  final RecordDetailPageArguments arguments;

  const RecordDetailPage({
    super.key,
    required this.arguments,
  });

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  final ExamRecordRepository _recordRepository = getIt.get();
  final AppCubit _appCubit = getIt.get();
  final RecordListCubit _recordListCubit = getIt.get();

  ExamRecord? _record;
  bool _isDeleting = false;

  Future<void> _refreshRecord() async {
    ExamRecord? getRecord() {
      return _recordListCubit.state.originalRecords
          .firstWhereOrNull((r) => r.id == widget.arguments.recordId);
    }

    ExamRecord? record = getRecord();

    if (record == null) {
      await _recordListCubit.refresh();
      record = getRecord();
    }

    setState(() {
      _record = record;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshRecord();
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;

    if (record == null) {
      return const Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomMenuBar(),
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ProgressOverlay(
        isProgressing: _isDeleting,
        description: '삭제하는 중',
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomMenuBar(
                actionButtons: [
                  ActionButton(
                    icon: const Icon(Icons.download),
                    tooltip: '이미지 저장',
                    onPressed: () => _onSaveImageButtonPressed(record),
                  ),
                  ActionButton(
                    icon: const Icon(Icons.edit),
                    tooltip: '수정',
                    onPressed: () => _onEditButtonPressed(record),
                  ),
                  ActionButton(
                    icon: const Icon(Icons.delete),
                    tooltip: '삭제',
                    onPressed: () => _onDeleteButtonPressed(record),
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildContent(record),
                        ),
                      ),
                    ),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            SilgamApp.backgroundColor,
                            SilgamApp.backgroundColor.withAlpha(0),
                          ],
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

  Widget _buildContent(ExamRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 2,
                color: Color(record.getGradeColor()),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: _buildTitle(record),
              ),
            ],
          ),
        ),
        if (record.score != null ||
            record.grade != null ||
            record.percentile != null ||
            record.standardScore != null ||
            record.examDurationMinutes != null)
          Column(
            children: [
              const SizedBox(height: 32),
              Center(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: _buildScoreBoard(record),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        if (record.wrongProblems.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSubTitle('틀린 문제'),
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children: [
                  for (final wrongProblem in record.wrongProblems)
                    Chip(
                      label: Text('${wrongProblem.problemNumber}번'),
                      backgroundColor: Theme.of(context).primaryColor,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ],
          ),
        if (record.feedback.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSubTitle('피드백'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.feedback,
                  style: const TextStyle(height: 1.2),
                ),
              ),
            ],
          ),
        if (record.reviewProblems.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSubTitle('복습할 문제'),
              const SizedBox(height: 8),
              GridView.extent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final problem in record.reviewProblems)
                    ReviewProblemCard(
                      problem: problem,
                      onTap: () => _onReviewProblemCardTap(problem),
                    ),
                ],
              )
            ],
          ),
        const SizedBox(height: 16),
        BlocBuilder<AppCubit, AppState>(
          buildWhen: (previous, current) =>
              previous.productBenefit.isAdsRemoved !=
              current.productBenefit.isAdsRemoved,
          builder: (context, appState) {
            if (isAdmobDisabled || appState.productBenefit.isAdsRemoved) {
              return const SizedBox.shrink();
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                return AdTile(
                  width: constraints.maxWidth.toInt(),
                  margin: const EdgeInsets.only(bottom: 20),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitle(ExamRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMEd('ko_KR').add_Hm().format(record.examStartedTime),
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                record.exam.name,
                style: TextStyle(
                  color: Color(record.exam.color),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBoard(ExamRecord record) {
    int? score = record.score;
    int? grade = record.grade;
    int? percentile = record.percentile;
    int? standardScore = record.standardScore;
    int? examDurationMinutes = record.examDurationMinutes;

    final List<Widget> scoreItems = [
      if (score != null) _buildScoreItem('점수', score),
      if (grade != null) _buildScoreItem('등급', grade),
      if (percentile != null) _buildScoreItem('백분위', percentile),
      if (standardScore != null) _buildScoreItem('표준점수', standardScore),
      if (examDurationMinutes != null)
        _buildScoreItem('응시 시간', examDurationMinutes),
    ];

    for (var i = scoreItems.length - 1; i >= 0; i--) {
      if (i == 0) continue;
      scoreItems.insert(i, const VerticalDivider(indent: 6, endIndent: 6));
    }

    return IntrinsicHeight(
      child: Row(
        children: scoreItems,
      ),
    );
  }

  Widget _buildScoreItem(String title, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
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
      ),
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  void _onSaveImageButtonPressed(ExamRecord record) async {
    final arguments = SaveImagePageArguments(recordToSave: record);
    await Navigator.pushNamed(context, SaveImagePage.routeName,
        arguments: arguments);
  }

  void _onEditButtonPressed(ExamRecord record) async {
    final arguments = EditRecordPageArguments(recordToEdit: record);
    await Navigator.pushNamed(
      context,
      EditRecordPage.routeName,
      arguments: arguments,
    );

    await _refreshRecord();
  }

  void _onDeleteButtonPressed(ExamRecord record) {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'delete_record_confirm_dialog'),
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '정말 이 기록을 삭제하실 건가요?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(record.title),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteRecord(record);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecord(ExamRecord record) async {
    if (_appCubit.state.isOffline &&
        record.reviewProblems.any((p) => p.imagePaths.isNotEmpty)) {
      EasyLoading.showToast(
        '오프라인 상태에서는 복습할 문제 사진을 포함한 기록을 삭제할 수 없어요.',
        dismissOnTap: true,
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });
    await _recordRepository.deleteExamRecord(record);
    _recordListCubit.onRecordDeleted(record);

    if (mounted) Navigator.pop(context, RecordDetailPageResult.deleted);

    await AnalyticsManager.logEvent(
        name: '[ExamRecordDetailPage] Delete exam record');
  }

  void _onReviewProblemCardTap(ReviewProblem problem) {
    final arguments = ReviewProblemDetailPageArguments(problem: problem);
    Navigator.pushNamed(context, ReviewProblemDetailPage.routeName,
        arguments: arguments);
  }
}

class RecordDetailPageArguments {
  final String recordId;

  RecordDetailPageArguments({required this.recordId});
}

enum RecordDetailPageResult {
  deleted,
}
