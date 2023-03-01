part of 'main_view.dart';

class _ExamStartCard extends StatefulWidget {
  const _ExamStartCard({
    Key? key,
  }) : super(key: key);

  @override
  _ExamStartCardState createState() => _ExamStartCardState();
}

class _ExamStartCardState extends State<_ExamStartCard>
    with TickerProviderStateMixin {
  late final TabController _subjectController = TabController(
    length: defaultExams.length + 1,
    initialIndex: 1,
    vsync: this,
  )..addListener(_onTapSelected);
  Exam? _selectedExam = defaultExams[0];

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
                Container(
                  height: 2,
                  color: disabledColor,
                ),
                TabBar(
                  controller: _subjectController,
                  isScrollable: true,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: disabledColor,
                  labelStyle:
                      defaultTextStyle?.copyWith(fontWeight: FontWeight.w900),
                  unselectedLabelStyle:
                      defaultTextStyle?.copyWith(fontWeight: FontWeight.w500),
                  tabs: [
                    const Tab(text: '전과목'),
                    for (Exam exam in defaultExams) Tab(text: exam.examName),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_selectedExam != null) _buildExamLayout(_selectedExam!),
          if (_selectedExam == null) _buildAllSubjectExamLayout(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildExamLayout(Exam exam) {
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
                title: '시험 시간',
                content: exam.getExamTimeString(),
                badgeText: '${exam.examDuration}분',
              ),
              const SizedBox(height: 16),
              _buildInfo(
                iconData: Icons.text_snippet_outlined,
                title: '문제 수 / 만점',
                content: '${exam.numberOfQuestions}문제 / ${exam.perfectScore}점',
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Ink(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E2A7C),
                Color(0xFF283593),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(16),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _onExamStartTap(exam),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [],
          ),
        ),
        const SizedBox(width: 20),
        Ink(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E2A7C),
                Color(0xFF283593),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(16),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          child: InkWell(
            onTap: () {},
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
    final index = _subjectController.index;
    if (index == 0) {
      setState(() {
        _selectedExam = null;
      });
    } else {
      Exam exam = defaultExams[index - 1];
      if (_selectedExam != exam) {
        setState(() {
          _selectedExam = exam;
        });
      }
    }
  }

  void _onExamStartTap(Exam exam) async {
    await Navigator.pushNamed(
      context,
      ClockPage.routeName,
      arguments: ClockPageArguments(exam),
    );
    if (mounted) {
      context.read<HomeCubit>().changeTabByTitle(RecordListView.title);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
  }
}
