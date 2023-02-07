import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/exam_record.dart';
import '../../../model/subject.dart';
import '../../../util/injection.dart';
import '../../app/cubit/app_cubit.dart';
import '../../common/custom_card.dart';
import '../../common/login_button.dart';
import '../../common/scaffold_body.dart';
import '../../common/subject_filter_chip.dart';
import '../../login_page/login_page.dart';
import '../record_list/cubit/record_list_cubit.dart';
import 'cubit/stat_cubit.dart';

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
  static const EdgeInsets _cardMargin =
      EdgeInsets.symmetric(vertical: 8, horizontal: 20);
  static final TextStyle _titleTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade800,
  );

  final StatCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocListener<RecordListCubit, RecordListState>(
        bloc: getIt.get(),
        listenWhen: (previous, current) =>
            previous.originalRecords != current.originalRecords,
        listener: (_, recordListState) =>
            _cubit.onOriginalRecordsUpdated(recordListState.originalRecords),
        child: BlocBuilder<AppCubit, AppState>(
          buildWhen: (previous, current) =>
              previous.isSignedIn != current.isSignedIn,
          builder: (context, appState) {
            return BlocBuilder<StatCubit, StatState>(
              builder: (context, state) {
                return ScaffoldBody(
                  title: StatView.title,
                  isRefreshing: state.isLoading,
                  onRefresh: appState.isSignedIn ? _cubit.refresh : null,
                  slivers: [
                    if (appState.isNotSignedIn) _buildLoginButton(),
                    if (appState.isSignedIn) _buildBody(state),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(StatState state) {
    final Map<Subject, List<ExamRecord>> filteredRecords =
        state.originalRecords.groupListsBy((record) => record.subject)
          ..removeWhere(
            (subject, records) =>
                records.isEmpty ||
                (state.selectedSubjects.isNotEmpty &&
                    !state.selectedSubjects.contains(subject)),
          );
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              const SizedBox(width: 20),
              for (Subject subject in Subject.values)
                SubjectFilterChip(
                  subject: subject,
                  isSelected: state.selectedSubjects.contains(subject),
                  onSelected: () => _cubit.onSubjectFilterButtonTapped(subject),
                ),
              const SizedBox(width: 17),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildValueGraphsCard(
          filteredRecords: filteredRecords,
          examValueType: state.selectedExamValueType,
          selectedSubjects: state.selectedSubjects,
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: CustomCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomCard(
                  margin: _cardMargin.subtract(
                    EdgeInsets.only(left: _cardMargin.left),
                  ),
                  child: Container(),
                ),
              )
            ],
          ),
        ),
        _buildInfoCard(
          title: '지금까지 모의고사를 푼 시간',
          text: Duration(
            minutes: filteredRecords.values.flattened
                .map((e) => e.examDurationMinutes)
                .whereNotNull()
                .sum,
          ).toStringFormat(),
        ),
        _buildInfoCard(
          title: '지금까지 푼 모의고사 개수',
          text: '${filteredRecords.values.flattened.length}개',
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildValueGraphsCard({
    required Map<Subject, List<ExamRecord>> filteredRecords,
    required ExamValueType examValueType,
    required List<Subject> selectedSubjects,
  }) {
    return CustomCard(
      margin: _cardMargin,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
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
              ),
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
        isCurved: true,
        preventCurveOverShooting: true,
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

  Widget _buildPieChart({
    required final Map<Subject, List<ExamRecord>> filteredRecords,
  }) {
    final totalValue = filteredRecords.values.flattened.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - _cardMargin.horizontal - 12) / 2;
    return MediaQuery(
      data: const MediaQueryData(textScaleFactor: 1.0),
      child: PieChart(
        swapAnimationDuration: Duration.zero,
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: filteredRecords.entries.map((entry) {
            final subject = entry.key;
            final records = entry.value;
            final value = records.length;
            final ratio = value / totalValue;
            return PieChartSectionData(
              color: Color(subject.firstColor),
              value: value.toDouble(),
              showTitle: false,
              radius: cardWidth / 2 - 16,
              badgePositionPercentageOffset: ratio == 1
                  ? 0
                  : ratio > 0.3
                      ? 0.5
                      : 0.85 - ratio,
              badgeWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ratio >= 0.1)
                    Text(
                      subject.subjectName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (_titleTextStyle.fontSize ?? 14) - 2,
                      ),
                    ),
                  if (ratio >= 0.1) const SizedBox(height: 4),
                  if (ratio >= 0.025)
                    Text(
                      '$value개',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (_titleTextStyle.fontSize ?? 14) - 3,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String text}) {
    return CustomCard(
      margin: _cardMargin,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildLoginButton() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: LoginButton(
          onTap: _onLoginTap,
          description: '통계 기능을 사용하려면 로그인해주세요!',
        ),
      ),
    );
  }

  void _onLoginTap() {
    Navigator.pushNamed(context, LoginPage.routeName);
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
