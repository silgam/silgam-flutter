import 'package:flutter/material.dart';

import '../../repository/exam_repository.dart';
import '../app/app.dart';
import '../clock_page/breakpoint.dart';
import '../common/custom_menu_bar.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  static const routeName = '/timetable';

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final EdgeInsets _cardPadding =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  final BorderRadius _cardBorderRadius = BorderRadius.circular(5);
  final double _timelineWidth = 4;
  late final Color _pageBackgroundColor = Theme.of(context).primaryColor;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: darkSystemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: _pageBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const CustomMenuBar(
                title: '전과목 시험보기',
                lightText: true,
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 40),
                    _buildStartTile(
                      time: DateTime.now(),
                      isChecked: true,
                      onTap: () {},
                    ),
                    _buildTimeTile(
                      title: defaultExams[0].examName,
                      startTime: defaultExams[0].examStartTime,
                      duration: defaultExams[0].examDuration,
                      breakpoints:
                          Breakpoint.createBreakpointsFromExam(defaultExams[0]),
                      primaryColor: Color(defaultExams[0].subject.secondColor),
                    ),
                    _buildTimeTile(
                      title: defaultExams[1].examName,
                      startTime: defaultExams[1].examStartTime,
                      duration: defaultExams[1].examDuration,
                      breakpoints:
                          Breakpoint.createBreakpointsFromExam(defaultExams[1]),
                      primaryColor: Color(defaultExams[1].subject.secondColor),
                    ),
                    _buildTimeTile(
                      title: defaultExams[2].examName,
                      startTime: defaultExams[2].examStartTime,
                      duration: defaultExams[2].examDuration,
                      breakpoints:
                          Breakpoint.createBreakpointsFromExam(defaultExams[2]),
                      primaryColor: Color(defaultExams[2].subject.secondColor),
                    ),
                    _buildTimeTile(
                      title: defaultExams[3].examName,
                      startTime: defaultExams[3].examStartTime,
                      duration: defaultExams[3].examDuration,
                      breakpoints:
                          Breakpoint.createBreakpointsFromExam(defaultExams[3]),
                      primaryColor: Color(defaultExams[3].subject.secondColor),
                    ),
                    _buildTimeTile(
                      title: defaultExams[4].examName,
                      startTime: defaultExams[4].examStartTime,
                      duration: defaultExams[4].examDuration,
                      breakpoints:
                          Breakpoint.createBreakpointsFromExam(defaultExams[4]),
                      primaryColor: Color(defaultExams[4].subject.secondColor),
                    ),
                    _buildTimeTile(
                      title: defaultExams[5].examName,
                      startTime: defaultExams[5].examStartTime,
                      duration: defaultExams[5].examDuration,
                      breakpoints:
                          Breakpoint.createBreakpointsFromExam(defaultExams[5]),
                      primaryColor: Color(defaultExams[5].subject.secondColor),
                    ),
                    _buildTimeTile(
                      title: '쉬는시간',
                      startTime: defaultExams[2].examStartTime,
                      duration: defaultExams[2].examDuration,
                    ),
                    _buildEndTile(time: DateTime.now()),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartTile({
    required DateTime? time,
    required bool isChecked,
    required GestureTapCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildTimeText(time),
            const SizedBox(width: 16),
            Expanded(
              child: Material(
                borderRadius: _cardBorderRadius,
                color: isChecked ? Colors.white : Colors.transparent,
                child: InkWell(
                  borderRadius: _cardBorderRadius,
                  splashColor: Colors.transparent,
                  onTap: onTap,
                  child: Container(
                    padding:
                        _cardPadding.subtract(EdgeInsets.all(_timelineWidth)),
                    decoration: BoxDecoration(
                      borderRadius: _cardBorderRadius,
                      border: Border.all(
                        color: Colors.white,
                        width: _timelineWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '감독관 입실 안내 방송',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isChecked ? Colors.black : Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Checkbox(
                          value: isChecked,
                          onChanged: (_) => onTap(),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          splashRadius: 0,
                          fillColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.black;
                              }
                              return Colors.white;
                            },
                          ),
                          visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity,
                            vertical: VisualDensity.minimumDensity,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              const SizedBox(width: 88),
              Container(
                width: _timelineWidth,
                color: Colors.white,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildAddButton(onTap: () {}),
              ),
              const SizedBox(width: 20),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTimeTile({
    required String title,
    required DateTime startTime,
    required int duration,
    List<Breakpoint>? breakpoints,
    Color? primaryColor,
  }) {
    final textColor = primaryColor == null ? Colors.black : Colors.white;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeText(startTime),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: _timelineWidth,
                margin: const EdgeInsets.only(top: 10),
                color: primaryColor ?? Colors.white,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pageBackgroundColor,
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: primaryColor ?? Colors.white,
                      width: _timelineWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: _cardPadding,
                  decoration: BoxDecoration(
                    borderRadius: _cardBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        primaryColor ?? Colors.white,
                        if (primaryColor == null)
                          Colors.white
                        else
                          HSLColor.fromColor(primaryColor)
                              .withLightness(0.65)
                              .toColor(),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: textColor.withOpacity(0.15),
                                      border: Border.fromBorderSide(
                                        BorderSide(
                                          color: textColor,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '$duration분',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textColor,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          size: 18,
                                          color: textColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: primaryColor == null
                                  ? Colors.grey
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (breakpoints != null && breakpoints.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              const VerticalDivider(
                                color: Colors.white,
                                width: 2,
                                thickness: 2,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: breakpoints.map(
                                    (breakpoint) {
                                      final time = breakpoint.time;
                                      final hourString =
                                          time.hour.toTwoDigitString();
                                      final minuteString =
                                          time.minute.toTwoDigitString();
                                      return Text(
                                        '$hourString:$minuteString  ${breakpoint.title}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildAddButton(onTap: () {}),
              ],
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildEndTile({required DateTime? time}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildTimeText(time),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: _cardPadding.subtract(EdgeInsets.all(_timelineWidth)),
                decoration: BoxDecoration(
                  borderRadius: _cardBorderRadius,
                  border: Border.all(
                    color: Colors.white,
                    width: _timelineWidth,
                  ),
                ),
                child: const Text(
                  '시험 종료',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeText(DateTime? time) {
    return Container(
      alignment: Alignment.topRight,
      width: 64,
      child: Text(
        time != null ? '${time.hour}:${time.minute.toTwoDigitString()}' : '',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildAddButton({required GestureTapCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: _cardBorderRadius,
        onTap: onTap,
        splashColor: Colors.transparent,
        child: const SizedBox(
          width: double.infinity,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

extension on int {
  String toTwoDigitString() {
    return toString().padLeft(2, '0');
  }
}
