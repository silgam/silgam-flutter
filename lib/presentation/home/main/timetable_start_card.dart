part of 'main_view.dart';

class _TimetableStartCard extends StatefulWidget {
  const _TimetableStartCard({
    Key? key,
  }) : super(key: key);

  @override
  _TimetableStartCardState createState() => _TimetableStartCardState();
}

class _TimetableStartCardState extends State<_TimetableStartCard>
    with TickerProviderStateMixin {
  final timetables = defaultTimetables;

  late final TabController _tabController = TabController(
    length: timetables.length,
    initialIndex: 0,
    vsync: this,
  )..addListener(_onTapSelected);
  Timetable? _selectedTimetable = defaultTimetables.first;

  @override
  Widget build(BuildContext context) {
    _onTapSelected(); // 과목명 변경됐을 때 현재 탭에 적용
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
                Container(
                  height: 2,
                  color: disabledColor,
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: disabledColor,
                  labelStyle:
                      defaultTextStyle?.copyWith(fontWeight: FontWeight.w900),
                  unselectedLabelStyle:
                      defaultTextStyle?.copyWith(fontWeight: FontWeight.w500),
                  tabs: [
                    // const Tab(text: '전과목'),
                    for (Timetable timetable in timetables)
                      Tab(text: timetable.name),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_selectedTimetable != null) _buildTabLayout(_selectedTimetable!),
          if (_selectedTimetable == null) _buildAllSubjectExamLayout(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTabLayout(Timetable timetable) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfo(
                iconData: Icons.schedule,
                title: timetable.items.length > 1 ? '총 시간' : '시험 시간',
                content: timetable.startTime.toPeriodString(timetable.endTime),
                badgeText: timetable.duration.toKoreanString(),
              ),
              const SizedBox(height: 16),
              timetable.items.length > 1
                  ? _buildInfo(
                      iconData: Icons.text_snippet_outlined,
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
        const SizedBox(width: 20),
        Ink(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E2A7C),
                Color(0xFF283593),
              ],
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

  Widget _buildInfo({
    required IconData iconData,
    required String title,
    required String content,
    String? badgeText,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconData,
          size: 28,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (badgeText != null) const SizedBox(width: 6),
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

  Widget _buildAllSubjectExamLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 32),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
        ),
        const SizedBox(width: 20),
        Ink(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E2A7C),
                Color(0xFF283593),
              ],
            ),
          ),
          child: InkWell(
            onTap: _onAllSubjectExamStartTap,
            splashColor: Colors.transparent,
            highlightColor: Colors.grey.withAlpha(60),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                '시험시작',
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

  void _onTapSelected() async {
    final index = _tabController.index;
    Timetable timetable = defaultTimetables[index];
    if (_selectedTimetable != timetable) {
      setState(() {
        _selectedTimetable = timetable;
      });
    }
  }

  void _onTimetableStartTap(Timetable timetable) async {
    await Navigator.pushNamed(
      context,
      ClockPage.routeName,
      arguments: ClockPageArguments(timetable),
    );
    if (mounted) {
      context.read<HomeCubit>().changeTabByTitle(RecordListView.title);
    }
  }

  void _onAllSubjectExamStartTap() {
    Navigator.pushNamed(context, TimetablePage.routeName);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
