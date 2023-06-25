import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../model/exam_detail.dart';
import '../../model/lap_time.dart';
import '../../model/subject.dart';
import '../../util/analytics_manager.dart';
import '../../util/date_time_extension.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../clock_page/timeline.dart';
import '../common/custom_card.dart';
import '../common/free_user_block_overlay.dart';
import '../edit_record_page/edit_record_page.dart';
import 'cubit/exam_overview_cubit.dart';

part 'exam_overview_messages.dart';

class ExamOverviewPage extends StatefulWidget {
  const ExamOverviewPage({
    super.key,
    required this.examDetail,
  });

  static const routeName = '/exam_overview';
  final ExamDetail examDetail;

  @override
  State<ExamOverviewPage> createState() => _ExamOverviewPageState();
}

class _ExamOverviewPageState extends State<ExamOverviewPage> {
  static const _tabletLayoutWidth = 800.0;
  static final TextStyle _titleTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade800,
  );
  static final TextStyle _contentTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Colors.grey.shade900,
    height: 1.2,
  );
  final AppCubit _appCubit = getIt.get();

  void _onCloseButtonPressed() {
    Navigator.of(context).pop();

    AnalyticsManager.logEvent(
      name: '[ExamOverviewPage] Close button pressed',
      properties: {
        'exam_detail': widget.examDetail.toString(),
      },
    );
  }

  void _onCopyLapTimePressed({
    required List<LapTimeItemGroup> lapTimeItemGroups,
    required bool isUsingExample,
  }) {
    final textToCopy = lapTimeItemGroups.toCopyableString();
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('복사되었습니다.'),
      ),
    );

    AnalyticsManager.logEvent(
      name: '[ExamOverviewPage] Copy lap time button pressed',
      properties: {
        'copy_text': textToCopy,
        'is_example': isUsingExample,
        'exam_detail': widget.examDetail.toString(),
      },
    );
  }

  void _onBottomButtonPressed({
    required List<LapTimeItemGroup> lapTimeItemGroups,
    required bool isUsingExample,
  }) {
    Navigator.of(context).pop();

    if (_appCubit.state.isSignedIn) {
      final arguments = EditRecordPageArguments(
        inputExam: widget.examDetail.exams.first,
        examStartedTime: widget.examDetail.examStartedTime,
        examFinishedTime: widget.examDetail.examFinishedTime,
        prefillFeedback: (lapTimeItemGroups.isItemsEmpty || isUsingExample)
            ? null
            : lapTimeItemGroups.toCopyableString(),
      );
      Navigator.pushNamed(
        context,
        EditRecordPage.routeName,
        arguments: arguments,
      );
    }

    AnalyticsManager.logEvent(
      name: '[ExamOverviewPage] Go to record button pressed',
      properties: {
        'exam_detail': widget.examDetail.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider<ExamOverviewCubit>(
      create: (_) => getIt.get(param1: widget.examDetail),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ExamOverviewCubit, ExamOverviewState>(
            builder: (context, state) {
              return screenWidth > _tabletLayoutWidth
                  ? _buildTabletLayout(state)
                  : _buildMobileLayout(state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ExamOverviewState state) {
    const horizontalPadding = 24.0;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                _buildCloseButton(),
                const SizedBox(height: 16),
                _buildTitle(),
                const SizedBox(height: 40),
                _buildSubjectCard(),
                const SizedBox(height: 20),
                _buildExamTimeCard(),
                const SizedBox(height: 20),
                _buildLapTimeCard(
                  lapTimeItemGroups: state.lapTimeItemGroups,
                  isUsingExample: state.isUsingExampleLapTimeItemGroups,
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 20,
          ),
          child: _buildBottomButton(
            lapTimeItemGroups: state.lapTimeItemGroups,
            isUsingExample: state.isUsingExampleLapTimeItemGroups,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(ExamOverviewState state) {
    const horizontalPadding = 60.0;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(maxWidth: _tabletLayoutWidth),
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildTitle(),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildSubjectCard(),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        flex: 3,
                        child: _buildExamTimeCard(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildLapTimeCard(
                    lapTimeItemGroups: state.lapTimeItemGroups,
                    isUsingExample: state.isUsingExampleLapTimeItemGroups,
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 20,
          ),
          child: _buildBottomButton(
            lapTimeItemGroups: state.lapTimeItemGroups,
            isUsingExample: state.isUsingExampleLapTimeItemGroups,
          ),
        ),
        Positioned(
          top: 12,
          right: 20,
          child: _buildCloseButton(),
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        splashRadius: 20,
        icon: const Icon(Icons.close),
        onPressed: _onCloseButtonPressed,
      ),
    );
  }

  Widget _buildTitle() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        _examOverviewMessages[Random().nextInt(_examOverviewMessages.length)],
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildSubjectCard() {
    var subjects = widget.examDetail.exams.map((e) => e.subject).toList();
    if (subjects.contains(Subject.investigation)) {
      subjects = [Subject.investigation, Subject.investigation2];
    }
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Text(
            '과목',
            style: _titleTextStyle,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: subjects
                .map(
                  (subject) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      subject.subjectName,
                      style: _contentTextStyle.copyWith(
                        color: Color(subject.firstColor),
                      ),
                    ),
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _buildExamTimeCard() {
    String startedTimeString =
        DateFormat.Hm().format(widget.examDetail.examStartedTime);
    String finishedTimeString =
        DateFormat.Hm().format(widget.examDetail.examFinishedTime);
    int durationMinutes = widget.examDetail.examFinishedTime
        .difference(widget.examDetail.examStartedTime)
        .inMinutes;
    int durationSeconds = widget.examDetail.examFinishedTime
        .difference(widget.examDetail.examStartedTime)
        .inSeconds;
    return CustomCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Column(
        children: [
          Text(
            '시험을 본 시간',
            style: _titleTextStyle,
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$startedTimeString ~ $finishedTimeString',
                        style: _contentTextStyle,
                      ),
                      VerticalDivider(
                        color: Colors.grey.shade900,
                        width: 20,
                        thickness: 1.1,
                        indent: 6,
                        endIndent: 6,
                      ),
                      Text(
                        '$durationMinutes',
                        style: _contentTextStyle,
                      ),
                      const SizedBox(width: 1),
                      Text(
                        'm',
                        style: _contentTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${durationSeconds % 60}',
                        style: _contentTextStyle,
                      ),
                      const SizedBox(width: 1),
                      Text(
                        's',
                        style: _contentTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 2,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLapTimeCard({
    required List<LapTimeItemGroup> lapTimeItemGroups,
    required bool isUsingExample,
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Text(
                '랩타임',
                style: _titleTextStyle,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _onCopyLapTimePressed(
                    lapTimeItemGroups: lapTimeItemGroups,
                    isUsingExample: isUsingExample,
                  ),
                  splashColor: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  splashRadius: 24,
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  tooltip: '복사하기',
                  icon: const Icon(
                    Icons.copy,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          if (lapTimeItemGroups.isItemsEmpty &&
              _appCubit.state.productBenefit.isLapTimeAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: Text(
                _appCubit.state.productBenefit.isLapTimeAvailable &&
                        !_appCubit.useLapTime
                    ? '랩타임 기능이 꺼져있어요.\n설정에서 랩타임 기능을 켜보세요.'
                    : '기록된 랩타임이 없어요.\n시험 중에 LAP 버튼을 눌러 랩타임을 기록해보세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            )
          else
            Stack(
              children: [
                Column(
                  children: [
                    _buildLapTimeTimeline(
                      lapTimeItemGroups: lapTimeItemGroups,
                    ),
                    const SizedBox(height: 8),
                    const Divider(
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 2),
                    ...lapTimeItemGroups.map(
                      (lapTimeItemGroup) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '${DateFormat.Hm().format(lapTimeItemGroup.startTime)} / ${lapTimeItemGroup.title}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...lapTimeItemGroup.lapTimeItems.mapIndexed(
                            (index, lapTimeItem) => _buildLapTimeItem(
                              index: index,
                              time: lapTimeItem.time,
                              timeDifference: lapTimeItem.timeDifference,
                              timeElapsed: lapTimeItem.timeElapsed,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                if (isUsingExample)
                  Positioned.fill(
                    child: FreeUserBlockOverlay(
                      overlayColor: Colors.white.withOpacity(0.8),
                      text: '예시 데이터입니다.\n랩타임 기능은 실감패스 사용자만 이용 가능해요.',
                    ),
                  )
              ],
            )
        ],
      ),
    );
  }

  Widget _buildLapTimeTimeline({
    required List<LapTimeItemGroup> lapTimeItemGroups,
  }) {
    final startTime = lapTimeItemGroups.first.startTime;
    final endTime = widget.examDetail.exams.last.examEndTime;
    final durationSeconds = endTime.difference(startTime).inSeconds;

    final markerPositions = lapTimeItemGroups
        .map((group) => group.lapTimeItems)
        .flattened
        .map((lapTimeItem) =>
            lapTimeItem.time.difference(startTime).inSeconds / durationSeconds)
        .where((position) => position >= 0 && position <= 1)
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          TimelineConnector(
            1,
            1,
            unsetWidth: true,
            unsetHeight: true,
            enabledColor: Theme.of(context).primaryColor,
            markerPositions: markerPositions,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat.Hm().format(startTime),
                style: TextStyle(
                  height: 1,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                DateFormat.Hm().format(endTime),
                style: TextStyle(
                  height: 1,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLapTimeItem({
    required int index,
    required DateTime time,
    required Duration timeDifference,
    required Duration timeElapsed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                '${index + 1}',
                style: _contentTextStyle.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: _contentTextStyle.fontSize! - 5,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                DateFormat.Hms().format(time),
                style: _contentTextStyle.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: _contentTextStyle.fontSize! - 5,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DottedLine(
                  dashLength: 1,
                  dashColor: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '+ ${timeDifference.to2DigitString()}',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1,
                ),
              )
            ],
          ),
          Text(
            timeElapsed.to2DigitString(),
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required List<LapTimeItemGroup> lapTimeItemGroups,
    required bool isUsingExample,
  }) {
    return Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      shadowColor: Colors.black.withAlpha(180),
      child: InkWell(
        onTap: () => _onBottomButtonPressed(
          lapTimeItemGroups: lapTimeItemGroups,
          isUsingExample: isUsingExample,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.grey.withAlpha(60),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Text(
                '기록하러 가기',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Positioned(
                right: 0,
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 32,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExamOverviewPageArguments {
  const ExamOverviewPageArguments({
    required this.examDetail,
  });

  final ExamDetail examDetail;
}
