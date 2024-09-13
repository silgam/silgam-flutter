import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

import '../../../model/exam.dart';
import '../../../model/exam_record.dart';
import '../../../util/const.dart';
import '../../../util/date_time_extension.dart';
import '../../../util/injection.dart';
import '../../app/cubit/app_cubit.dart';
import '../../common/custom_card.dart';
import '../../common/filter_action_chip.dart';
import '../../common/free_user_block_overlay.dart';
import '../../common/scaffold_body.dart';
import '../../common/search_field.dart';
import '../../common/subject_filter_chip.dart';
import '../cubit/home_cubit.dart';
import '../home_page.dart';
import '../record_list/cubit/record_list_cubit.dart';
import 'cubit/stat_cubit.dart';

class StatView extends StatefulWidget {
  const StatView({super.key});

  static const title = '통계';

  @override
  State<StatView> createState() => _StatViewState();
}

class _StatViewState extends State<StatView> {
  static const EdgeInsets _cardMargin = EdgeInsets.symmetric(vertical: 8);
  static final TextStyle _titleTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade800,
  );
  static const _cardBetweenMarginHorizontal = 12.0;
  static const _cardPaddingHorizontal = 16.0;
  static const _cardPaddingVertical = 16.0;

  final StatCubit _cubit = getIt.get();

  void _onDateRangeButtonPressed() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: _cubit.state.defaultDateRange.start,
      lastDate: _cubit.state.defaultDateRange.end,
      initialDateRange: _cubit.state.dateRange,
      switchToCalendarEntryModeIcon: const Icon(
        Icons.date_range,
        color: Colors.white,
      ),
    );
    if (picked != null) {
      _cubit.onDateRangeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider.value(
      value: _cubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (previous, current) =>
                previous.tabIndex != current.tabIndex,
            listener: (context, state) {
              final statViewTabIndex =
                  HomePage.views.keys.toList().indexOf(StatView.title);
              if (state.tabIndex == statViewTabIndex) {
                _cubit.refresh();
              }
            },
          ),
          BlocListener<RecordListCubit, RecordListState>(
            bloc: getIt.get(),
            listenWhen: (previous, current) =>
                previous.originalRecords != current.originalRecords,
            listener: (_, recordListState) => _cubit.onOriginalRecordsUpdated(),
          ),
        ],
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, appState) {
            return BlocBuilder<StatCubit, StatState>(
              builder: (context, state) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ScaffoldBody(
                      title: StatView.title,
                      isRefreshing: state.isLoading,
                      onRefresh: appState.isSignedIn ? _cubit.refresh : null,
                      slivers: [
                        _buildFilterChips(
                          isDateRangeSet: state.isDateRangeSet,
                          dateRange: state.dateRange,
                          exams: appState.getAllExams(),
                          selectedExamIds: state.selectedExamIds,
                        ),
                        screenWidth > tabletScreenWidth
                            ? _buildTabletLayout(
                                filteredRecords: state.records,
                                selectedExamIds: state.selectedExamIds,
                                selectedExamValueType:
                                    state.selectedExamValueType,
                              )
                            : _buildMobileLayout(
                                filteredRecords: state.records,
                                selectedExamIds: state.selectedExamIds,
                                selectedExamValueType:
                                    state.selectedExamValueType,
                              ),
                      ],
                    ),
                    if (!appState.productBenefit.isStatisticAvailable)
                      const FreeUserBlockOverlay(
                        text: '예시 데이터입니다.\n통계 기능은 실감패스 사용자만 이용 가능해요.',
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabletLayout({
    required Map<Exam, List<ExamRecord>> filteredRecords,
    required List<String> selectedExamIds,
    required ExamValueType selectedExamValueType,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildValueGraphsCard(
                    filteredRecords: filteredRecords,
                    examValueType: selectedExamValueType,
                    selectedExamIds: selectedExamIds,
                  ),
                  _buildTotalExamDurationInfoCard(
                    filteredRecords: filteredRecords,
                  ),
                  _buildTotalExamCountInfoCard(
                    filteredRecords: filteredRecords,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  _buildPieChartCard(filteredRecords: filteredRecords),
                  _buildHeatmapChartCard(
                    filteredRecords: filteredRecords,
                    expandHeight: false,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildMobileLayout({
    required Map<Exam, List<ExamRecord>> filteredRecords,
    required List<String> selectedExamIds,
    required ExamValueType selectedExamValueType,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 12),
        _buildValueGraphsCard(
          filteredRecords: filteredRecords,
          examValueType: selectedExamValueType,
          selectedExamIds: selectedExamIds,
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildPieChartCard(filteredRecords: filteredRecords),
              ),
              const SizedBox(width: _cardBetweenMarginHorizontal),
              Expanded(
                child: _buildHeatmapChartCard(
                  filteredRecords: filteredRecords,
                  expandHeight: true,
                ),
              )
            ],
          ),
        ),
        _buildTotalExamDurationInfoCard(filteredRecords: filteredRecords),
        _buildTotalExamCountInfoCard(filteredRecords: filteredRecords),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildFilterChips({
    required bool isDateRangeSet,
    required DateTimeRange dateRange,
    required List<Exam> exams,
    required List<String> selectedExamIds,
  }) {
    if (!exams.map((e) => e.id).toSet().containsAll(selectedExamIds)) {
      _cubit.onFilterResetButtonTapped();
    }

    return NonPaddingChildBuilder(
      builder: (horizontalPadding) {
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: SearchField(
                  onChanged: (value) => _cubit.onSearchTextChanged(value),
                  hintText: '제목 검색',
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    SizedBox(width: horizontalPadding),
                    FilterActionChip(
                      label: Icon(
                        Icons.replay,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: _cubit.onFilterResetButtonTapped,
                      tooltip: '초기화',
                    ),
                    const SizedBox(width: 6),
                    FilterActionChip(
                      label: Text(
                        isDateRangeSet
                            ? '${DateFormat.yMd('ko_KR').format(dateRange.start)}'
                                ' ~ ${DateFormat.yMd('ko_KR').format(dateRange.end)}'
                            : '전체 기간',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      onPressed: _onDateRangeButtonPressed,
                      tooltip: '기간 설정',
                    ),
                    const SizedBox(width: 6),
                    for (Exam exam
                        in exams.where((exam) => exam.name.isNotEmpty))
                      ExamFilterChip(
                        exam: exam,
                        isSelected: selectedExamIds.contains(exam.id),
                        onSelected: () => _cubit.onExamFilterButtonTapped(exam),
                      ),
                    SizedBox(width: horizontalPadding),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValueGraphsCard({
    required Map<Exam, List<ExamRecord>> filteredRecords,
    required ExamValueType examValueType,
    required List<String> selectedExamIds,
  }) {
    final isAllPerfectScoresSame = 1 ==
        filteredRecords.keys.map((exam) => exam.perfectScore).toSet().length;
    final average = filteredRecords.values.flattened
        .map((record) => examValueType.getValue(record))
        .whereNotNull()
        .averageOrNull
        ?.toStringAsFixed(1);
    return CustomCard(
      margin: _cardMargin,
      padding: const EdgeInsets.symmetric(
        horizontal: _cardBetweenMarginHorizontal - 4,
        vertical: _cardPaddingVertical - 4,
      ),
      clipBehavior: Clip.none,
      child: Column(
        children: [
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '과목별',
                style: _titleTextStyle,
              ),
              const SizedBox(width: 6),
              _buildExamValueTypeDropdown(examValueType),
              const SizedBox(width: 6),
              Text(
                '그래프',
                style: _titleTextStyle,
              ),
              examValueType == ExamValueType.scoreRatio
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Tooltip(
                        message: '''모든 과목의 만점을 100점으로 환산해서 볼 수 있어요.

예시1: 만점이 50점인 과목의 점수가 40점 -> 보정 점수 80점
예시2: 만점이 20점인 과목의 점수가 10점 -> 보정 점수 50점

환산식: 보정 점수 = (취득 점수 / 만점) x 100''',
                        triggerMode: TooltipTriggerMode.tap,
                        showDuration: const Duration(seconds: 5),
                        textStyle: const TextStyle(
                          height: 1.4,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Icon(
                          Icons.help_outline,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 3 / 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildValueGraphs(
                  examValueType: examValueType,
                  recordsMap: filteredRecords.map(
                    (exam, records) => MapEntry(
                      exam,
                      records
                          .where((record) =>
                              examValueType.getValue(record) != null)
                          .sortedBy((record) => record.examStartedTime),
                    ),
                  )..removeWhere((subject, records) => records.isEmpty),
                  cardWidth: constraints.maxWidth,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '평균',
                textAlign: TextAlign.center,
                style: _titleTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                !isAllPerfectScoresSame || average == null
                    ? '-'
                    : '$average${examValueType.postfix}',
                textAlign: TextAlign.center,
                style: _titleTextStyle.copyWith(),
              ),
              if (!isAllPerfectScoresSame || average == null)
                const SizedBox(width: 6),
              if (!isAllPerfectScoresSame || average == null)
                Tooltip(
                  message: isAllPerfectScoresSame
                      ? '1개 이상의 기록이 있을 때에만 평균 계산이 가능해요'
                      : '평균 계산은 만점이 같은 과목들끼리만 가능해요',
                  triggerMode: TooltipTriggerMode.tap,
                  child: Icon(
                    Icons.info_outline,
                    size: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildValueGraphs({
    required Map<Exam, List<ExamRecord>> recordsMap,
    required ExamValueType examValueType,
    required double cardWidth,
  }) {
    final allRecords = recordsMap.values.flattened;
    final dateToRecordsMap = SplayTreeMap<String, List<ExamRecord>>();
    recordsMap.forEach((subject, records) {
      records.forEachIndexed((index, record) {
        final date = record.examStartedTime.toDate();
        final sameDateLength = records
            .take(index)
            .where((element) => element.examStartedTime.toDate() == date)
            .length;
        final monthString = date.month.toString().padLeft(2, '0');
        final dayString = date.day.toString().padLeft(2, '0');
        final key = '${date.year}.$monthString.$dayString.$sameDateLength';
        dateToRecordsMap[key] ??= [];
        dateToRecordsMap[key]!.add(record);
      });
    });

    final values = allRecords.map((record) => examValueType.getValue(record)!);
    var minValue = (values.minOrNull ?? examValueType.minValue) *
        examValueType.reverseMultiple;
    var maxValue = (values.maxOrNull ?? examValueType.maxValue) *
        examValueType.reverseMultiple;
    if (examValueType.reverse && values.isNotEmpty) {
      final temp = minValue;
      minValue = maxValue;
      maxValue = temp;
    }
    final minMaxGap = maxValue - minValue;
    final maxLength = dateToRecordsMap.length;

    final lineBarsData = recordsMap.entries.map((entry) {
      final exam = entry.key;
      final color = Color(exam.color);
      return LineChartBarData(
        color: color,
        barWidth: (4 - dateToRecordsMap.keys.length * 0.015).clamp(2, 4),
        isStrokeCapRound: true,
        isStrokeJoinRound: true,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: FlDotData(
          getDotPainter: (p0, p1, p2, p3) {
            return FlDotCirclePainter(
              radius: 2,
              color: Colors.white,
              strokeWidth:
                  (2 - dateToRecordsMap.keys.length * 0.005).clamp(1, 2),
              strokeColor: color,
            );
          },
        ),
        spots: [
          ...dateToRecordsMap.entries.mapIndexed((index, entry) {
            final record = entry.value.where((record) => record.exam == exam);
            return record.isEmpty
                ? null
                : FlSpot(
                    index.toDouble(),
                    examValueType.getValue(record.first)!.toDouble() *
                        examValueType.reverseMultiple,
                  );
          }).whereNotNull(),
        ],
      );
    }).toList();
    final lineTouchData = LineTouchData(
      touchSpotThreshold: 10,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((spotIndex) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: barData.color ?? Colors.black,
              dashArray: [5, 5],
              strokeWidth: 1,
            ),
            FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: barData.color ?? Colors.black,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
          );
        }).toList();
      },
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        maxContentWidth: cardWidth - 20,
        getTooltipColor: (_) => Colors.white,
        tooltipBorder: const BorderSide(color: Colors.grey),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            final exam = recordsMap.keys.toList()[touchedSpot.barIndex];
            final records =
                dateToRecordsMap.entries.elementAt(touchedSpot.x.toInt()).value;
            final record = records.firstWhere((record) => record.exam == exam);
            final value = touchedSpot.y.toInt() * examValueType.reverseMultiple;
            return LineTooltipItem(
              record.title,
              const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: ' $value${examValueType.postfix}',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: '  ${exam.name}',
                  style: TextStyle(
                    color: Color(exam.color),
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    height: 1,
                  ),
                )
              ],
            );
          }).toList();
        },
      ),
    );
    final titleData = FlTitlesData(
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        drawBelowEverything: true,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: minMaxGap < 10 ? 1 : null,
          getTitlesWidget: (value, meta) {
            if (value == meta.min ||
                value == meta.max ||
                (!examValueType.reverse && value < 0) ||
                (examValueType.reverse && value > -1)) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(right: 6),
              alignment: Alignment.centerRight,
              child: Text(
                (value * examValueType.reverseMultiple).toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        drawBelowEverything: true,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 16,
          getTitlesWidget: (value, meta) {
            if (value == meta.max ||
                value - value.truncate() != 0 ||
                value >= dateToRecordsMap.length) {
              return const SizedBox.shrink();
            }
            final index = value.toInt();
            final key = dateToRecordsMap.keys.elementAt(index);
            final keySplits = key.split('.')..removeLast();
            final isAlreadyShown =
                dateToRecordsMap.keys.take(index).any((previousKey) {
              return (previousKey.split('.')..removeLast()).join() ==
                  keySplits.join();
            });
            if (isAlreadyShown && meta.appliedInterval < 2) {
              return const SizedBox.shrink();
            }
            return Container(
              alignment: Alignment.bottomCenter,
              child: Text(
                keySplits.getRange(1, 3).map((e) => int.parse(e)).join('/'),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
    );
    final borderData = FlBorderData(
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade300),
        left: BorderSide(color: Colors.grey.shade300),
      ),
    );
    const gridData = FlGridData(show: false);
    return MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
      child: LineChart(
        duration: Duration.zero,
        LineChartData(
          backgroundColor: Colors.white,
          minY: minValue - minMaxGap * 0.1,
          maxY: maxValue + minMaxGap * 0.05,
          maxX: maxLength - 1 + maxLength * 0.05,
          lineBarsData: lineBarsData,
          lineTouchData: lineTouchData,
          titlesData: titleData,
          borderData: borderData,
          gridData: gridData,
        ),
      ),
    );
  }

  Widget _buildPieChartCard({
    required final Map<Exam, List<ExamRecord>> filteredRecords,
  }) {
    return CustomCard(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(
        horizontal: _cardPaddingHorizontal,
        vertical: _cardPaddingVertical,
      ),
      margin: _cardMargin.subtract(
        EdgeInsets.only(right: _cardMargin.right),
      ),
      child: Column(
        children: [
          Text(
            '과목별 푼 모의고사 수',
            textAlign: TextAlign.center,
            style: _titleTextStyle,
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: _buildPieChart(filteredRecords: filteredRecords),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart({
    required final Map<Exam, List<ExamRecord>> filteredRecords,
  }) {
    final totalValue = filteredRecords.values.flattened.length;

    int touchedIndex = -1;
    return MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
      child: LayoutBuilder(builder: (context, constraints) {
        return StatefulBuilder(builder: (context, setState) {
          return PieChart(
            swapAnimationCurve: Curves.easeOut,
            swapAnimationDuration: const Duration(milliseconds: 100),
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: filteredRecords.entries.mapIndexed((index, entry) {
                final exam = entry.key;
                final records = entry.value;
                final value = records.length;
                final ratio = value / totalValue;
                final isTouched = touchedIndex == index;
                return PieChartSectionData(
                  color: Color(exam.color),
                  value: value.toDouble() * (isTouched ? 3 : 1),
                  showTitle: false,
                  radius: (constraints.maxWidth / 2) * (isTouched ? 1.05 : 1),
                  badgePositionPercentageOffset: ratio == 1
                      ? 0
                      : ratio > 0.3
                          ? 0.5
                          : 0.85 - ratio,
                  badgeWidget: isTouched || touchedIndex == -1
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isTouched || ratio >= 0.1)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isTouched ? double.infinity : 60,
                                ),
                                child: Text(
                                  exam.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        (_titleTextStyle.fontSize ?? 14) - 2,
                                  ),
                                ),
                              ),
                            if (isTouched || ratio >= 0.1)
                              const SizedBox(height: 4),
                            if (isTouched || ratio >= 0.025)
                              Text(
                                '$value개',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      (_titleTextStyle.fontSize ?? 14) - 3,
                                ),
                              ),
                          ],
                        )
                      : null,
                );
              }).toList(),
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          );
        });
      }),
    );
  }

  Widget _buildHeatmapChartCard({
    required Map<Exam, List<ExamRecord>> filteredRecords,
    required bool expandHeight,
  }) {
    return CustomCard(
      padding: const EdgeInsets.only(
        top: _cardPaddingVertical,
        left: _cardPaddingHorizontal,
        right: _cardPaddingHorizontal,
      ),
      margin: _cardMargin.subtract(
        EdgeInsets.only(left: _cardMargin.left),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '푼 모의고사 수 히트맵',
            textAlign: TextAlign.center,
            style: _titleTextStyle,
          ),
          if (!expandHeight) const SizedBox(height: 12),
          if (expandHeight) const Spacer(),
          _buildHeatmapChart(
            filteredRecords: filteredRecords,
          ),
          if (expandHeight) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeatmapChart({
    required Map<Exam, List<ExamRecord>> filteredRecords,
  }) {
    final datasets = filteredRecords.values.flattened
        .groupListsBy((record) => record.examStartedTime.toDate())
        .map((date, records) => MapEntry(date, records.length));

    MapEntry<DateTime, int>? touchedData;
    Timer? dismissTimer;
    return MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
          children: [
            HeatMapCalendar(
              showColorTip: false,
              flexible: true,
              borderRadius: 2,
              monthFontSize: 10,
              weekFontSize: 10,
              fontSize: 10,
              defaultColor: Colors.black.withOpacity(0.04),
              textColor: Colors.grey,
              secondaryTextColor: Colors.white,
              weekTextColor: Colors.grey,
              monthTextColor: Colors.grey.shade700,
              initDate: DateTime.now(),
              datasets: datasets,
              colorsets: const {
                0: Color.fromARGB(255, 57, 83, 211),
              },
              onClick: (date) {
                final value = datasets[date] ?? 0;
                setState(() {
                  touchedData = MapEntry(date, value);
                  dismissTimer?.cancel();
                  dismissTimer = Timer(
                    const Duration(milliseconds: 2000),
                    () {
                      setState(() {
                        touchedData = null;
                      });
                    },
                  );
                });
              },
            ),
            Container(
              height: _cardPaddingVertical,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 4, right: 4, top: 2),
              child: Text(
                touchedData != null ? '${touchedData!.value}개' : '',
                maxLines: 1,
                style: TextStyle(
                  height: 1,
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTotalExamDurationInfoCard({
    required Map<Exam, List<ExamRecord>> filteredRecords,
  }) {
    return _buildInfoCard(
      title: '지금까지 모의고사를 푼 시간',
      text: Duration(
        minutes: filteredRecords.values.flattened
            .map((e) => e.examDurationMinutes)
            .whereNotNull()
            .sum,
      ).toStringFormat(),
    );
  }

  Widget _buildTotalExamCountInfoCard({
    required Map<Exam, List<ExamRecord>> filteredRecords,
  }) {
    return _buildInfoCard(
      title: '지금까지 푼 모의고사 개수',
      text: '${filteredRecords.values.flattened.length}개',
    );
  }

  Widget _buildInfoCard({required String title, required String text}) {
    return CustomCard(
      margin: _cardMargin,
      padding: const EdgeInsets.symmetric(
        horizontal: _cardPaddingHorizontal,
        vertical: _cardPaddingVertical - 4,
      ),
      isThin: true,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: _titleTextStyle,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _titleTextStyle.color,
              fontSize: (_titleTextStyle.fontSize ?? 14) - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamValueTypeDropdown(ExamValueType examValueType) {
    return DropdownButton(
      value: examValueType,
      onChanged: _cubit.onExamValueTypeChanged,
      alignment: Alignment.center,
      isDense: true,
      items: ExamValueType.values
          .map((valueType) => DropdownMenuItem(
                value: valueType,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    valueType.name,
                    style: _titleTextStyle,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

enum ExamValueType {
  score(
    name: '점수',
    postfix: '점',
    getValue: getScore,
    minValue: 0,
    maxValue: 100,
  ),
  scoreRatio(
    name: '보정 점수',
    postfix: '점',
    getValue: getScoreRatio,
    minValue: 0,
    maxValue: 100,
  ),
  grade(
    name: '등급',
    postfix: '등급',
    getValue: getGrade,
    minValue: 9,
    maxValue: 1,
    reverse: true,
  ),
  percentile(
    name: '백분위',
    postfix: '%',
    getValue: getPercentile,
    minValue: 0,
    maxValue: 100,
  ),
  standardScore(
    name: '표준점수',
    postfix: '점',
    getValue: getStandardScore,
    minValue: 0,
    maxValue: 150,
  );

  const ExamValueType({
    required this.name,
    required this.postfix,
    required this.getValue,
    required this.minValue,
    required this.maxValue,
    this.reverse = false,
  });

  final String name;
  final String postfix;
  final int? Function(ExamRecord record) getValue;
  final int minValue;
  final int maxValue;
  final bool reverse;

  int get reverseMultiple => reverse ? -1 : 1;

  static int? getScore(ExamRecord record) => record.score;

  static int? getScoreRatio(ExamRecord record) {
    final perfectScore = record.exam.perfectScore;
    final score = record.score?.clamp(0, perfectScore);
    return score != null ? ((score / perfectScore) * 100).round() : null;
  }

  static int? getGrade(ExamRecord record) => record.grade;

  static int? getPercentile(ExamRecord record) => record.percentile;

  static int? getStandardScore(ExamRecord record) => record.standardScore;
}

extension on Duration {
  String toStringFormat() {
    final hours = inHours;
    final minutes = inMinutes - hours * 60;
    return '$hours시간 $minutes분';
  }
}

extension on Iterable<int> {
  double? get averageOrNull {
    if (isEmpty) {
      return null;
    }
    return average;
  }
}
