import 'package:flutter/material.dart';

import '../../clock_page/clock_page.dart';
import '../../model/exam.dart';
import '../../repository/exam_repository.dart';

class MainView extends StatelessWidget {
  static const title = '메인';
  final Function() navigateToRecordTab;

  const MainView({
    Key? key,
    required this.navigateToRecordTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ExamStartCard(navigateToRecordTab: navigateToRecordTab),
      ],
    );
  }
}

class _ExamStartCard extends StatefulWidget {
  final Function() navigateToRecordTab;

  const _ExamStartCard({
    Key? key,
    required this.navigateToRecordTab,
  }) : super(key: key);

  @override
  _ExamStartCardState createState() => _ExamStartCardState();
}

class _ExamStartCardState extends State<_ExamStartCard> with TickerProviderStateMixin {
  late final TabController _subjectController;
  Exam _selectedExam = ExamRepository.defaultExams[0];

  @override
  void initState() {
    super.initState();
    _subjectController = TabController(length: ExamRepository.defaultExams.length, vsync: this);
    _subjectController.addListener(() {
      final index = _subjectController.index;
      _selectedExam = ExamRepository.defaultExams[index];
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Color disabledColor = Theme.of(context).primaryColor.withAlpha(80);
    TextStyle? defaultTextStyle = Theme.of(context).primaryTextTheme.bodyLarge;
    return _Card(
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
                  labelStyle: defaultTextStyle?.copyWith(fontWeight: FontWeight.w900),
                  unselectedLabelStyle: defaultTextStyle?.copyWith(fontWeight: FontWeight.w500),
                  tabs: [
                    for (Exam exam in ExamRepository.defaultExams) Tab(text: exam.examName),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfo(
                      iconData: Icons.schedule,
                      title: '시험 시간',
                      content: _selectedExam.getExamTimeString(),
                    ),
                    const SizedBox(height: 16),
                    _buildInfo(
                      iconData: Icons.text_snippet_outlined,
                      title: '문제 수 / 만점',
                      content: '${_selectedExam.numberOfQuestions}문제 / ${_selectedExam.perfectScore}점',
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
                  onTap: _onExamStartTap,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.white.withAlpha(30),
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
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfo({
    required IconData iconData,
    required String title,
    required String content,
  }) {
    Color color = const Color(0xFF081146);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconData,
          color: color,
          size: 28,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onExamStartTap() async {
    await Navigator.pushNamed(
      context,
      ClockPage.routeName,
      arguments: ClockPageArguments(_selectedExam),
    );
    widget.navigateToRecordTab();
  }

  @override
  void dispose() {
    super.dispose();
    _subjectController.dispose();
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        child: child,
      ),
    );
  }
}
