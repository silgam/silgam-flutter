import 'package:flutter/material.dart';

import '../../clock_page/clock_page.dart';
import '../../model/exam.dart';
import '../../model/subject.dart';
import '../../repository/exam_repository.dart';
import '../../util/scaffold_body.dart';

class TakeExamView extends StatelessWidget {
  static const title = '시험보기';
  final Function() navigateToRecordTab;

  const TakeExamView({
    Key? key,
    required this.navigateToRecordTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldBody(
      title: title,
      child: SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _ExamCard(
              index: index,
              numberOfItems: ExamRepository.defaultExams.length,
              thisExam: ExamRepository.defaultExams[index],
              navigateToRecordTab: navigateToRecordTab,
            ),
            childCount: ExamRepository.defaultExams.length,
          ),
        ),
      ),
    );
  }
}

class _ExamCard extends StatefulWidget {
  final int index;
  final int numberOfItems;
  final Exam thisExam;
  final Function() navigateToRecordTab;

  const _ExamCard({
    required this.index,
    required this.numberOfItems,
    required this.thisExam,
    required this.navigateToRecordTab,
    Key? key,
  }) : super(key: key);

  @override
  _ExamCardState createState() => _ExamCardState();
}

class _ExamCardState extends State<_ExamCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: _buildGradientBoxDecoration(),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.white.withAlpha(30),
          onTap: _onCardTapped,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20, left: 20, right: 20),
            child: Column(
              children: [
                Text(
                  widget.thisExam.examName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                _TextWithIcon(
                  icon: Icons.schedule,
                  text: widget.thisExam.buildExamTimeString(),
                ),
                const SizedBox(height: 4),
                _TextWithIcon(
                  icon: Icons.text_snippet,
                  text: '${widget.thisExam.numberOfQuestions}문제 / ${widget.thisExam.perfectScore}점',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCardTapped() async {
    await Navigator.pushNamed(
      context,
      ClockPage.routeName,
      arguments: ClockPageArguments(widget.thisExam),
    );
    widget.navigateToRecordTab();
  }

  BoxDecoration _buildGradientBoxDecoration() {
    final Color startColor = Color(widget.thisExam.subject.firstColor);
    final Color endColor = Color(widget.thisExam.subject.secondColor);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          startColor,
          endColor,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: startColor.withAlpha(120),
          blurRadius: 6,
        ),
      ],
    );
  }
}

class _TextWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TextWithIcon({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 12,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
