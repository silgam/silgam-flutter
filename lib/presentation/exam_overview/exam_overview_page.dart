import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import '../../model/exam.dart';
import '../../model/exam_detail.dart';
import '../../model/exam_record.dart';
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
import '../record_detail/record_detail_page.dart';
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

  bool _isExpandableFabOpen = false;

  List<Exam> get _exams => widget.examDetail.exams;

  double get _screenWidth => MediaQuery.sizeOf(context).width;
  bool get _isTablet => _screenWidth > _tabletLayoutWidth;
  double get _horizontalPadding => _isTablet ? 60 : 24;
  double get _floatingButtonWidth =>
      _screenWidth -
      _horizontalPadding * 2 -
      MediaQuery.paddingOf(context).horizontal;

  Future<void> _autoSaveExamRecords() async {
    final autoSaveFailedExamNames =
        await _examOverviewCubit.autoSaveExamRecords();

    if (autoSaveFailedExamNames == null ||
        autoSaveFailedExamNames.isEmpty ||
        !mounted) {
      return;
    }

    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: '${ExamOverviewPage.routeName}/auto_save_failed_dialog',
      ),
      builder: (context) {
        final examRecordLimit =
            _appCubit.state.freeProductBenefit.examRecordLimit;
        final examsCount = _exams.length;

        return CustomAlertDialog(
          title: '시험 종료 후 자동 저장 기능 이용 제한 안내',
          content: examsCount > 1
              ? '''
실감패스를 이용하기 전까지는 모의고사 기록을 $examRecordLimit개까지만 저장할 수 있어요. 방금 응시하신 ${widget.examDetail.timetableName}에 포함된 $examsCount개의 과목들 중 다음 과목들은 자동으로 저장되지 않았어요.

${autoSaveFailedExamNames.join(', ')}

$examRecordLimit개 미만까지 모의고사 기록을 삭제하거나 실감패스를 이용하기 전까지는 자동 저장 기능이 비활성화될 예정이에요 😢'''
              : '''
실감패스를 이용하기 전까지는 모의고사 기록을 $examRecordLimit개까지만 저장할 수 있어요. 방금 응시하신 ${_exams.first.name} 과목의 기록은 자동으로 저장되지 않았어요.

$examRecordLimit개 미만까지 모의고사 기록을 삭제하거나 실감패스를 이용하기 전까지는 자동 저장 기능이 비활성화될 예정이에요 😢''',
          actions: [
            CustomTextButton.primary(
              text: '확인',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          scrollable: true,
        );
      },
    );
  }

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
        return CustomAlertDialog(
          title: '아직 시험 기록이 저장되지 않았어요!',
          content: content,
          actions: [
            CustomTextButton.secondary(
              text: '취소',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CustomTextButton.destructive(
              text: '나가기',
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

  Future<void> _onRecordExamButtonPressed(Exam exam) async {
    final examRecordId = _examOverviewCubit.state.examToRecordIds[exam];
    if (examRecordId != null) {
      final RecordDetailPageResult? recordDetailPageResult =
          await Navigator.pushNamed<RecordDetailPageResult>(
        context,
        RecordDetailPage.routeName,
        arguments: RecordDetailPageArguments(recordId: examRecordId),
      );

      if (recordDetailPageResult == RecordDetailPageResult.deleted) {
        _examOverviewCubit.examRecordDeleted(exam);
      }
      return;
    }

    if (_appCubit.state.isSignedIn) {
      final arguments = EditRecordPageArguments(
        inputExam: exam,
        examStartedTime: widget.examDetail.examStartedTimes[exam],
        examFinishedTime: widget.examDetail.examFinishedTimes[exam],
        prefillFeedback:
            _examOverviewCubit.state.getPrefillFeedbackForExamRecord(exam),
      );
      final ExamRecord? examRecord = await Navigator.pushNamed<ExamRecord>(
        context,
        EditRecordPage.routeName,
        arguments: arguments,
      );

      if (examRecord != null) {
        _examOverviewCubit.examRecorded(exam, examRecord.id);
      }
    } else {
      Navigator.pushNamed(context, LoginPage.routeName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 후 사용할 수 있는 기능이에요.'),
        ),
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
  void initState() {
    super.initState();
    _autoSaveExamRecords();
  }

  @override
  Widget build(BuildContext context) {
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
                _examOverviewCubit.updateLapTimeItemGroups();

                return BlocBuilder<ExamOverviewCubit, ExamOverviewState>(
                  builder: (context, state) {
                    return PopScope(
                      canPop: state.examToRecordIds.length == _exams.length,
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
      initialOpen: _isExpandableFabOpen,
      onOpen: () => _isExpandableFabOpen = true,
      onClose: () => _isExpandableFabOpen = false,
      openCloseStackAlignment: Alignment.centerRight,
      distance: 52,
      type: ExpandableFabType.up,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withAlpha(51),
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
                  width: _floatingButtonWidth,
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
                  width: _floatingButtonWidth,
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
                if (_exams.length > 1) _buildTimetableNameCard(),
                if (_exams.length > 1) const SizedBox(height: 20),
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
                  if (_exams.length > 1) _buildTimetableNameCard(),
                  if (_exams.length > 1) const SizedBox(height: 28),
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

  Widget _buildTimetableNameCard() {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Text(
            '시간표',
            style: _titleTextStyle,
          ),
          const SizedBox(height: 12),
          Text(
            widget.examDetail.timetableName,
            style: _contentTextStyle,
          ),
        ],
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
    final startedTime = widget.examDetail.timetableStartedTime;
    final finishedTime = widget.examDetail.timetableFinishedTime;
    final startedTimeString = DateFormat.Hm().format(startedTime);
    final finishedTimeString = DateFormat.Hm().format(finishedTime);
    final durationMinutes = finishedTime.difference(startedTime).inMinutes;
    final durationSeconds = finishedTime.difference(startedTime).inSeconds;

    return Tooltip(
      message: '예비령과 준비령, 쉬는 시간 등을 모두 포함하여 시험 화면에 머무른 총 응시 시간입니다.',
      triggerMode: TooltipTriggerMode.tap,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      showDuration: const Duration(seconds: 3),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '총 응시 시간',
                  style: _titleTextStyle,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.help_outline,
                  color: Colors.grey.shade500,
                  size: 16,
                )
              ],
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
                      const SizedBox(height: 8),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 28),
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
                              color: Colors.grey.shade700,
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
                                  color: Colors.grey.shade600,
                                  width: 0.7,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${DateFormat.Hm().format(lapTimeItemGroup.startTime)} / ${lapTimeItemGroup.title}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
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
                      overlayColor: Colors.white.withAlpha(204),
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
    final isUsingExample =
        _examOverviewCubit.state.isUsingExampleLapTimeItemGroups;
    final startTime = lapTimeItemGroups.first.startTime;
    final endTime = isUsingExample ? _exams.first.endTime : _exams.last.endTime;
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
    return BlocBuilder<ExamOverviewCubit, ExamOverviewState>(
      buildWhen: (previous, current) =>
          previous.isAutoSavingRecords != current.isAutoSavingRecords ||
          previous.examToRecordIds != current.examToRecordIds,
      builder: (context, state) {
        final isRecorded = state.examToRecordIds.containsKey(exam);
        final isAutoSaving = !isRecorded && state.isAutoSavingRecords;

        return Material(
          color: isRecorded ? Colors.grey.shade100 : Color(exam.color),
          shape: StadiumBorder(
            side: isRecorded
                ? BorderSide(
                    color: Color(exam.color),
                  )
                : BorderSide.none,
          ),
          clipBehavior: Clip.hardEdge,
          elevation: 5,
          shadowColor: Colors.black26,
          child: InkWell(
            onTap:
                isAutoSaving ? () {} : () => _onRecordExamButtonPressed(exam),
            splashFactory: NoSplash.splashFactory,
            child: Container(
              width: _floatingButtonWidth,
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
                        isRecorded
                            ? '${exam.name} 기록 확인하기'
                            : isAutoSaving
                                ? '${exam.name} 자동 저장 중'
                                : '${exam.name} 기록하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isRecorded ? Color(exam.color) : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: isAutoSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isRecorded ? Icons.check : Icons.chevron_right,
                            color:
                                isRecorded ? Color(exam.color) : Colors.white,
                            size: 24,
                          ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ExamOverviewPageArguments {
  const ExamOverviewPageArguments({
    required this.examDetail,
  });

  final ExamDetail examDetail;
}
