import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../model/exam_detail.dart';
import '../../util/injection.dart';
import '../common/custom_card.dart';
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
  static const _horizontalPadding = 24.0;
  static final TextStyle _titleTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.grey.shade700,
  );
  static final TextStyle _contentTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.grey.shade900,
    height: 1.4,
  );

  late final ExamOverviewCubit _cubit = getIt.get(
    param1: widget.examDetail,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCloseButton(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 40),
                _buildExamTimeCard(),
                const SizedBox(height: 20),
                _buildLapTimeCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
      ),
      child: IconButton(
        splashRadius: 20,
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
      ),
      child: FittedBox(
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
      margin: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
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
                  size: 32,
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
                        color: Colors.grey.shade600,
                        width: 20,
                        thickness: 0.7,
                        indent: 2,
                        endIndent: 2,
                      ),
                      Text(
                        '$durationMinutes',
                        style: _contentTextStyle,
                      ),
                      const SizedBox(width: 1),
                      Text(
                        'm',
                        style: _contentTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
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
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
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
    return CustomCard(
      margin: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),
      child: Column(
        children: [
          Text(
            '랩 타임',
            style: _titleTextStyle,
          ),
          const SizedBox(height: 12),
          Column(
            children: _cubit.state.lapTimeItemGroups
                .map(
                  (lapTimeItemGroup) => Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        '${lapTimeItemGroup.title} (${DateFormat.Hm().format(lapTimeItemGroup.startTime)})',
                        style: TextStyle(
                          color: _contentTextStyle.color,
                        ),
                      ),
                      const SizedBox(height: 2),
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
                )
                .toList(),
          )
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
      child: Row(
        children: [
          Text(
            '${index + 1}',
            style: _contentTextStyle.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat.Hms().format(time),
            style: _contentTextStyle.copyWith(
              fontWeight: FontWeight.w500,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${timeDifference.isNegative ? '-' : '+'}'
                ' '
                '${timeDifference.inMinutes.abs().toString().padLeft(2, '0')}'
                ':'
                '${(timeDifference.inSeconds.abs() % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${timeElapsed.inMinutes.toString().padLeft(2, '0')}'
                ':'
                '${(timeElapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          )
        ],
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
