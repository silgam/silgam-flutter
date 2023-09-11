import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../../../model/exam_record.dart';
import '../../../model/subject.dart';
import '../../../util/const.dart';
import '../../../util/injection.dart';
import '../../app/cubit/app_cubit.dart';
import '../../common/custom_card.dart';
import '../../common/free_user_block_overlay.dart';
import '../../common/scaffold_body.dart';
import '../../common/search_field.dart';
import '../../common/subject_filter_chip.dart';
import '../cubit/home_cubit.dart';
import '../home_page.dart';
import '../record_list/cubit/record_list_cubit.dart';
import 'cubit/stat_cubit.dart';
import 'example_records.dart';

class StatView extends StatefulWidget {
  const StatView({super.key});

  static const title = '통계';
  static final examValueTypes = [
    ExamValueType(
      name: '점수',
      postfix: '점',
      getValue: (record) => record.score,
      minValue: 0,
      maxValue: 100,
    ),
    ExamValueType(
      name: '등급',
      postfix: '등급',
      getValue: (record) => record.grade,
      minValue: 9,
      maxValue: 1,
      reverse: true,
    ),
    ExamValueType(
      name: '백분위',
      postfix: '%',
      getValue: (record) => record.percentile,
      minValue: 0,
      maxValue: 100,
    ),
    ExamValueType(
      name: '표준점수',
      postfix: '점',
      getValue: (record) => record.standardScore,
      minValue: 0,
      maxValue: 150,
    ),
  ];

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
            listener: (_, recordListState) => _cubit
                .onOriginalRecordsUpdated(recordListState.originalRecords),
          ),
        ],
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, appState) {
            return BlocBuilder<StatCubit, StatState>(
              builder: (context, state) {
                var records = appState.productBenefit.isStatisticAvailable
                    ? state.originalRecords
                    : exampleRecords;
                if (state.searchQuery.isNotEmpty) {
                  records = records
                      .where(
                          (record) => record.title.contains(state.searchQuery))
                      .toList();
                }
                final Map<Subject, List<ExamRecord>> filteredRecords =
                    records.groupListsBy((record) => record.subject)
                      ..removeWhere(
                        (subject, records) =>
                            records.isEmpty ||
                            (state.selectedSubjects.isNotEmpty &&
                                !state.selectedSubjects.contains(subject)),
                      );
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ScaffoldBody(
                      title: StatView.title,
                      isRefreshing: state.isLoading,
                      onRefresh: appState.isSignedIn ? _cubit.refresh : null,
                      slivers: [
                        _buildSubjectFilterChips(
                          selectedSubjects: state.selectedSubjects,
                        ),
                        screenWidth > tabletScreenWidth
                            ? _buildTabletLayout(
                                filteredRecords: filteredRecords,
                                selectedSubjects: state.selectedSubjects,
                                selectedExamValueType:
                                    state.selectedExamValueType,
                              )
                            : _buildMobileLayout(
                                filteredRecords: filteredRecords,
                                selectedSubjects: state.selectedSubjects,
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
    required Map<Subject, List<ExamRecord>> filteredRecords,
    required List<Subject> selectedSubjects,
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
                    selectedSubjects: selectedSubjects,
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
    required Map<Subject, List<ExamRecord>> filteredRecords,
    required List<Subject> selectedSubjects,
    required ExamValueType selectedExamValueType,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 12),
        _buildValueGraphsCard(
          filteredRecords: filteredRecords,
          examValueType: selectedExamValueType,
          selectedSubjects: selectedSubjects,
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

  Widget _buildSubjectFilterChips({required List<Subject> selectedSubjects}) {
    return NonPaddingChildBuilder(
      builder: (horizontalPadding) {
        return SliverToBoxAdapter(
          child: Column(
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
                    ActionChip(
                      label: Icon(
                        Icons.replay,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: _cubit.onFilterResetButtonTapped,
                      tooltip: '초기화',
                      pressElevation: 0,
                      backgroundColor: Colors.grey.shade700.withAlpha(10),
                      padding: EdgeInsets.zero,
                      side: BorderSide(
                        color: Colors.grey.shade700,
                        width: 0.4,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 6),
                    for (Subject subject in Subject.values)
                      SubjectFilterChip(
                        subject: subject,
                        isSelected: selectedSubjects.contains(subject),
                        onSelected: () =>
                            _cubit.onSubjectFilterButtonTapped(subject),
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
    required Map<Subject, List<ExamRecord>> filteredRecords,
    required ExamValueType examValueType,
    required List<Subject> selectedSubjects,
  }) {
    return CustomCard(
      margin: _cardMargin,
      padding: const EdgeInsets.only(
        left: _cardBetweenMarginHorizontal - 4,
        right: _cardBetweenMarginHorizontal - 4,
        bottom: 12,
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
              const SizedBox(width: 4),
              ButtonTheme(
                child: DropdownButton(
                  value: examValueType,
                  onChanged: _cubit.onExamValueTypeChanged,
                  alignment: Alignment.center,
                  items: StatView.examValueTypes
                      .map((valueType) => DropdownMenuItem(
                            value: valueType,
                            alignment: Alignment.center,
                            child: Text(
                              valueType.name,
                              style: _titleTextStyle,
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '그래프',
                style: _titleTextStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 3 / 2,
            child: _buildValueGraphs(
              examValueType: examValueType,
              recordsMap: filteredRecords.map(
                (subject, records) => MapEntry(
                  subject,
                  records
                      .where((record) => examValueType.getValue(record) != null)
                      .sortedBy((record) => record.examStartedTime),
                ),
              )..removeWhere((subject, records) => records.isEmpty),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueGraphs({
    required Map<Subject, List<ExamRecord>> recordsMap,
    required ExamValueType examValueType,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    final allRecords = recordsMap.values.flattened;
    final dateToRecordsMap = SplayTreeMap<String, List<ExamRecord>>();
    recordsMap.forEach((subject, records) {
      records.forEachIndexed((index, record) {
        final date = record.examStartedTime.toDateOnly();
        final sameDateLength = records
            .take(index)
            .where((element) => element.examStartedTime.toDateOnly() == date)
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
      final subject = entry.key;
      final color = Color(subject.firstColor);
      return LineChartBarData(
        color: color,
        barWidth: 4,
        belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
        dotData: FlDotData(
          getDotPainter: (p0, p1, p2, p3) {
            return FlDotCirclePainter(
              radius: 2,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: color,
            );
          },
        ),
        spots: [
          ...dateToRecordsMap.entries
              .mapIndexed((index, entry) {
                final record =
                    entry.value.where((record) => record.subject == subject);
                return record.isEmpty
                    ? null
                    : FlSpot(
                        index.toDouble(),
                        examValueType.getValue(record.first)!.toDouble() *
                            examValueType.reverseMultiple,
                      );
              })
              .whereNotNull()
              .toList(),
        ],
      );
    }).toList();
    final lineTouchData = LineTouchData(
      touchSpotThreshold: 10,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((spotIndex) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: barData.color,
              dashArray: [5, 5],
              strokeWidth: 1,
            ),
            FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: barData.color,
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
        maxContentWidth: screenWidth * 0.8,
        tooltipBgColor: Colors.white,
        tooltipBorder: const BorderSide(color: Colors.grey),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            final subject = recordsMap.keys.toList()[touchedSpot.barIndex];
            final records =
                dateToRecordsMap.entries.elementAt(touchedSpot.x.toInt()).value;
            final record =
                records.firstWhere((record) => record.subject == subject);
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
                  text: '  ${subject.subjectName}',
                  style: TextStyle(
                    color: Color(subject.firstColor),
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
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        drawBehindEverything: true,
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
        drawBehindEverything: true,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 16,
          getTitlesWidget: (value, meta) {
            if (value == meta.max || value - value.truncate() != 0) {
              return const SizedBox.shrink();
            }
            final index = value.toInt();
            final key = dateToRecordsMap.keys.elementAt(index);
            final keySplitted = key.split('.')..removeLast();
            final isAlreadyShown =
                dateToRecordsMap.keys.take(index).any((previousKey) {
              return (previousKey.split('.')..removeLast()).join() ==
                  keySplitted.join();
            });
            if (isAlreadyShown && meta.appliedInterval < 2) {
              return const SizedBox.shrink();
            }
            return Container(
              alignment: Alignment.bottomCenter,
              child: Text(
                keySplitted.getRange(1, 3).map((e) => int.parse(e)).join('/'),
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
    final gridData = FlGridData(show: false);
    return MediaQuery(
      data: const MediaQueryData(textScaleFactor: 1.0),
      child: LineChart(
        swapAnimationDuration: Duration.zero,
        LineChartData(
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
    required final Map<Subject, List<ExamRecord>> filteredRecords,
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
    required final Map<Subject, List<ExamRecord>> filteredRecords,
  }) {
    final totalValue = filteredRecords.values.flattened.length;

    int touchedIndex = -1;
    return MediaQuery(
      data: const MediaQueryData(textScaleFactor: 1.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return StatefulBuilder(builder: (context, setState) {
          return PieChart(
            swapAnimationCurve: Curves.easeOut,
            swapAnimationDuration: const Duration(milliseconds: 100),
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: filteredRecords.entries.mapIndexed((index, entry) {
                final subject = entry.key;
                final records = entry.value;
                final value = records.length;
                final ratio = value / totalValue;
                final isTouched = touchedIndex == index;
                return PieChartSectionData(
                  color: Color(subject.firstColor),
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
                              Text(
                                subject.subjectName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      (_titleTextStyle.fontSize ?? 14) - 2,
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
    required Map<Subject, List<ExamRecord>> filteredRecords,
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
    required Map<Subject, List<ExamRecord>> filteredRecords,
  }) {
    final datasets = filteredRecords.values.flattened
        .groupListsBy((record) => record.examStartedTime.toDateOnly())
        .map((date, records) => MapEntry(date, records.length));

    MapEntry<DateTime, int>? touchedData;
    Timer? dismissTimer;
    return MediaQuery(
      data: const MediaQueryData(textScaleFactor: 1.0),
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
    required Map<Subject, List<ExamRecord>> filteredRecords,
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
    required Map<Subject, List<ExamRecord>> filteredRecords,
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
}

class ExamValueType {
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
}

extension on DateTime {
  DateTime toDateOnly() {
    return DateTime(year, month, day);
  }
}

extension on Duration {
  String toStringFormat() {
    final hours = inHours;
    final minutes = inMinutes - hours * 60;
    return '$hours시간 $minutes분';
  }
}
