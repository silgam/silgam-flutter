import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:intl/intl.dart';

import '../../model/exam.dart';
import '../../model/exam_detail.dart';
import '../../model/lap_time.dart';
import '../../util/analytics_manager.dart';
import '../../util/date_time_extension.dart';
import '../../util/injection.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../clock/timeline.dart';
import '../common/custom_card.dart';
import '../common/free_user_block_overlay.dart';
import '../edit_record/edit_record_page.dart';
import '../login/login_page.dart';
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
  late final ExamOverviewCubit _examOverviewCubit =
      getIt.get(param1: widget.examDetail);

  final _randomTitle =
      _examOverviewMessages[Random().nextInt(_examOverviewMessages.length)];

  List<Exam> get _exams => widget.examDetail.exams;

  double get _screenWidth => MediaQuery.of(context).size.width;
  bool get _isTablet => _screenWidth > _tabletLayoutWidth;
  double get _horizontalPadding => _isTablet ? 60 : 24;
  double get _screenHorizontalPadding =>
      MediaQuery.of(context).padding.horizontal;

  void _onPopInvokedWithResult(bool didPop, _) {
    if (didPop) return;
    _showExitConfirmDialog();
  }

  void _showExitConfirmDialog() {
    var content = '랩타임과 모의고사 기록을 저장하지 않고 나가시겠어요?';
    if (widget.examDetail.lapTimes.isEmpty ||
        _examOverviewCubit.state.isUsingExampleLapTimeItemGroups) {
      content = '모의고사 기록을 저장하지 않고 나가시겠어요?';
    }

    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: '/exam_overview/close_dialog'),
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '아직 시험 기록이 저장되지 않았어요!',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(content),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text('취소'),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);

                AnalyticsManager.logEvent(
                  name: '[ExamOverviewPage-CloseDialog] Exit button pressed',
                  properties: {
                    'exam_detail': widget.examDetail.toString(),
                  },
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('나가기'),
            ),
          ],
        );
      },
    );

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
    final textToCopy = lapTimeItemGroups.toCopyableString(
      isExample: isUsingExample,
    );
    Clipboard.setData(ClipboardData(text: textToCopy));
    EasyLoading.showToast(
      '복사되었습니다.',
      dismissOnTap: true,
      duration: const Duration(milliseconds: 500),
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

  void _onBottomButtonPressed(Exam exam) {
    final isSignedIn = _appCubit.state.isSignedIn;
    final lapTimeItemGroups =
        _examOverviewCubit.state.examToLapTimeItemGroups[exam] ?? [];
    final isUsingExample =
        _examOverviewCubit.state.isUsingExampleLapTimeItemGroups;

    if (isSignedIn) {
      final arguments = EditRecordPageArguments(
        inputExam: exam,
        examStartedTime: widget.examDetail.examStartedTime,
        examFinishedTime: widget.examDetail.examFinishedTime,
        prefillFeedback: (lapTimeItemGroups.isEmpty || isUsingExample)
            ? null
            : lapTimeItemGroups.toCopyableString(),
      );
      Navigator.pushNamed(
        context,
        EditRecordPage.routeName,
        arguments: arguments,
      );
      _examOverviewCubit.examRecorded(exam.id);
    } else {
      Navigator.pushNamed(
        context,
        LoginPage.routeName,
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
    // TODO: Example 이상하게 보이는거 수정, 복사했을 때 스낵바 안뜨는거 수정
    return BlocProvider<ExamOverviewCubit>(
      create: (_) => _examOverviewCubit,
      child: AnnotatedRegion(
        value: defaultSystemUiOverlayStyle,
        child: Scaffold(
          floatingActionButtonLocation:
              _exams.length > 1 ? ExpandableFab.location : null,
          floatingActionButton: _exams.length > 1 ? _buildFab() : null,
          body: SafeArea(
            child: BlocBuilder<AppCubit, AppState>(
              builder: (context, appState) {
                _examOverviewCubit.initialize();
                return BlocBuilder<ExamOverviewCubit, ExamOverviewState>(
                  builder: (context, state) {
                    return PopScope(
                      canPop: state.recordedExamIds.length == _exams.length,
                      onPopInvokedWithResult: _onPopInvokedWithResult,
                      child: _isTablet
                          ? _buildTabletLayout()
                          : _buildMobileLayout(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    final rightOffset = _horizontalPadding - 16;

    return ExpandableFab(
      openCloseStackAlignment: Alignment.centerRight,
      distance: 52,
      type: ExpandableFabType.up,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.2),
        blur: 8,
      ),
      childrenOffset: Offset(rightOffset, 8),
      childrenAnimation: ExpandableFabAnimation.none,
      openButtonBuilder: FloatingActionButtonBuilder(
        size: 60,
        builder: (_, onPressed, progress) {
          return Padding(
            padding: EdgeInsets.only(right: rightOffset),
            child: Material(
              color: Theme.of(context).primaryColor,
              shape: const StadiumBorder(),
              clipBehavior: Clip.hardEdge,
              elevation: 5,
              child: InkWell(
                onTap: onPressed,
                splashFactory: NoSplash.splashFactory,
                child: Container(
                  width: _screenWidth -
                      _horizontalPadding * 2 -
                      _screenHorizontalPadding,
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '기록하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      closeButtonBuilder: FloatingActionButtonBuilder(
        size: 60,
        builder: (_, onPressed, progress) {
          return Padding(
            padding: EdgeInsets.only(right: rightOffset),
            child: Material(
              color: Colors.white,
              shape: const StadiumBorder(),
              clipBehavior: Clip.hardEdge,
              elevation: 5,
              shadowColor: Colors.black26,
              child: InkWell(
                onTap: onPressed,
                splashFactory: NoSplash.splashFactory,
                child: Container(
                  width: _screenWidth -
                      _horizontalPadding * 2 -
                      _screenHorizontalPadding,
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '닫기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      children: _exams.reversed.map(_buildRecordExamButton).toList(),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
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
                _buildLapTimeCard(),
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
        if (_exams.length == 1)
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.bottomCenter,
            child: _buildRecordExamButton(_exams.first),
          ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(maxWidth: _tabletLayoutWidth),
              padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildTitle(),
                  const SizedBox(height: 32),
                  _buildSubjectCard(),
                  const SizedBox(height: 28),
                  _buildExamTimeCard(),
                  const SizedBox(height: 28),
                  _buildLapTimeCard(),
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),
        ),
        if (_exams.length == 1)
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.bottomCenter,
            child: _buildRecordExamButton(_exams.first),
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
        onPressed: () {
          Navigator.maybePop(context);
        },
      ),
    );
  }

  Widget _buildTitle() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        _randomTitle,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildSubjectCard() {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Text(
            '과목',
            style: _titleTextStyle,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            children: _exams
                .map(
                  (exam) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      exam.name,
                      textAlign: TextAlign.center,
                      style: _contentTextStyle.copyWith(
                        color: Color(exam.color),
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

  Widget _buildLapTimeCard() {
    final examToLapTimeItemGroups =
        _examOverviewCubit.state.examToLapTimeItemGroups;
    final isUsingExample =
        _examOverviewCubit.state.isUsingExampleLapTimeItemGroups;
    final isLapTimeAvailable =
        _appCubit.state.productBenefit.isLapTimeAvailable;
    final useLapTime = _appCubit.useLapTime;

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
            ],
          ),
          const SizedBox(height: 8),
          if (examToLapTimeItemGroups.isEmpty && isLapTimeAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: Text(
                useLapTime
                    ? '기록된 랩타임이 없어요.\n시험 중에 LAP 버튼을 눌러 랩타임을 기록해보세요.'
                    : '랩타임 기능이 꺼져있어요.\n설정에서 랩타임 기능을 켜보세요.',
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
                    _buildLapTimeTimeline(),
                    for (final MapEntry(key: exam, value: lapTimeItemGroups)
                        in examToLapTimeItemGroups.entries) ...[
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Text(
                            exam.name,
                            style: TextStyle(
                              color: Color(exam.color),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => _onCopyLapTimePressed(
                                lapTimeItemGroups: lapTimeItemGroups,
                                isUsingExample: isUsingExample,
                              ),
                              padding: const EdgeInsets.all(0),
                              splashRadius: 24,
                              visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity,
                              ),
                              color: Color(exam.color),
                              tooltip: '복사하기',
                              icon: const Icon(
                                Icons.copy,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                      for (final lapTimeItemGroup in lapTimeItemGroups)
                        Column(
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
                            for (final (index, lapTimeItem)
                                in lapTimeItemGroup.lapTimeItems.indexed)
                              _buildLapTimeItem(
                                index: index,
                                time: lapTimeItem.time,
                                timeDifference: lapTimeItem.timeDifference,
                                timeElapsed: lapTimeItem.timeElapsed,
                              )
                          ],
                        ),
                    ]
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

  Widget _buildLapTimeTimeline() {
    final lapTimeItemGroups =
        _examOverviewCubit.state.examToLapTimeItemGroups.values.flattened;
    final startTime = lapTimeItemGroups.first.startTime;
    final endTime = _exams.last.endTime;
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

  Widget _buildRecordExamButton(Exam exam) {
    return Material(
      color: Color(exam.color),
      shape: const StadiumBorder(),
      clipBehavior: Clip.hardEdge,
      elevation: 5,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () => _onBottomButtonPressed(exam),
        splashFactory: NoSplash.splashFactory,
        child: Container(
          width:
              _screenWidth - _horizontalPadding * 2 - _screenHorizontalPadding,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${exam.name} 기록하기',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const Positioned(
                right: 0,
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 24,
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
