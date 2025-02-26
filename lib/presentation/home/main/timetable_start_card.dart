import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/timetable.dart';
import '../../../util/duration_extension.dart';
import '../../../util/injection.dart';
import '../../app/cubit/app_cubit.dart';
import '../../clock/clock_page.dart';
import '../../common/custom_card.dart';
import '../../common/dialog.dart';

class TimetableStartCard extends StatefulWidget {
  const TimetableStartCard({super.key, required this.timetables});

  final List<Timetable> timetables;

  @override
  State<TimetableStartCard> createState() => _TimetableStartCardState();
}

class _TimetableStartCardState extends State<TimetableStartCard>
    with TickerProviderStateMixin {
  final AppCubit _appCubit = getIt.get();

  TabController? _tabController;
  int _selectedTimetableIndex = 1;

  @override
  void initState() {
    super.initState();
    _updateTabController();
  }

  @override
  void didUpdateWidget(covariant TimetableStartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTabController();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  void _updateTabController() {
    if (_selectedTimetableIndex >= widget.timetables.length) {
      setState(() {
        _selectedTimetableIndex = 0;
      });
    }

    _tabController?.removeListener(_onTapSelected);
    _tabController?.dispose();
    _tabController = TabController(
      length: widget.timetables.length,
      initialIndex: _selectedTimetableIndex,
      vsync: this,
    )..addListener(_onTapSelected);
  }

  void _onTapSelected() async {
    final index = _tabController?.index ?? 0;
    if (_selectedTimetableIndex != index) {
      setState(() {
        _selectedTimetableIndex = index;
      });
    }
  }

  void _onTimetableStartTap(Timetable timetable) async {
    if (timetable.isAllSubjectsTimetable &&
        !_appCubit.state.productBenefit.isAllSubjectsTimetableAvailable) {
      showAllSubjectsTimetableNotAvailableDialog(context);
      return;
    }

    Navigator.pushNamed(
      context,
      ClockPage.routeName,
      arguments: ClockPageArguments(timetable),
    );
  }

  Widget _buildInfo({
    required IconData iconData,
    required String title,
    required String content,
    String? badgeText,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, size: 28),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                content,
                textWidthBasis: TextWidthBasis.longestLine,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabLayout() {
    final timetable = widget.timetables[_selectedTimetableIndex];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 32),
        Expanded(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                timetable.items.length > 1
                    ? _buildInfo(
                      iconData: Icons.schedule,
                      title: '총 시간',
                      content:
                          '${DateFormat.Hm().format(timetable.startTime)} ~ ${DateFormat.Hm().format(timetable.endTime)}',
                      badgeText: timetable.duration.toKoreanString(),
                    )
                    : _buildInfo(
                      iconData: Icons.schedule,
                      title: '시험 시간',
                      content:
                          '${DateFormat.Hm().format(timetable.items.first.exam.startTime)} ~ ${DateFormat.Hm().format(timetable.items.first.exam.endTime)}',
                      badgeText:
                          '${timetable.items.first.exam.durationMinutes}분',
                    ),
                const SizedBox(height: 16),
                timetable.items.length > 1
                    ? _buildInfo(
                      iconData: Icons.style,
                      title: '과목',
                      content: timetable.toExamNamesString(),
                    )
                    : _buildInfo(
                      iconData: Icons.text_snippet_outlined,
                      title: '문제 수 / 만점',
                      content:
                          '${timetable.items.first.exam.numberOfQuestions}문제 / ${timetable.items.first.exam.perfectScore}점',
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        Ink(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF1E2A7C), Color(0xFF283593)],
            ),
          ),
          child: InkWell(
            onTap: () => _onTimetableStartTap(timetable),
            splashColor: Colors.transparent,
            highlightColor: Colors.grey.withAlpha(60),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                '시험 시작',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color disabledColor = Theme.of(context).primaryColor.withAlpha(80);
    TextStyle? defaultTextStyle = Theme.of(context).primaryTextTheme.bodyLarge;
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          IntrinsicWidth(
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(height: 2, color: disabledColor),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: disabledColor,
                  labelStyle: defaultTextStyle?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  unselectedLabelStyle: defaultTextStyle?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  tabs:
                      widget.timetables
                          .map((timetable) => Tab(text: timetable.name))
                          .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTabLayout(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
