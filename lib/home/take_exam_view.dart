import 'package:flutter/material.dart';

import '../clock_page/clock_page.dart';
import '../model/exam.dart';
import '../model/subject.dart';
import '../repository/exam_repository.dart';
import '../util/scaffold_body.dart';

class TakeExamView extends StatelessWidget {
  static const title = '시험보기';

  const TakeExamView({Key? key}) : super(key: key);

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

  const _ExamCard({
    required this.index,
    required this.numberOfItems,
    required this.thisExam,
    Key? key,
  }) : super(key: key);

  @override
  _ExamCardState createState() => _ExamCardState();
}

class _ExamCardState extends State<_ExamCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onCardTapped,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        padding: const EdgeInsets.only(top: 12, bottom: 20, left: 20, right: 20),
        decoration: _buildGradientBoxDecoration(),
        child: Column(
          children: [
            Text(
              widget.thisExam.subject.name,
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
    );
  }

  void _onCardTapped() {
    Navigator.pushNamed(
      context,
      ClockPage.routeName,
      arguments: ClockPageArguments(widget.thisExam),
    );
  }

  BoxDecoration _buildGradientBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _getGradientColor(widget.index / (widget.numberOfItems - 1)),
          _getGradientColor((widget.index + 1) / (widget.numberOfItems - 1)),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: _getGradientColor(
            (widget.index + 1) / (widget.numberOfItems - 1),
          ).withAlpha(120),
          blurRadius: 6,
        ),
      ],
    );
  }

  Color _getGradientColor(double t) {
    final startColor = HSVColor.fromColor(const Color(0xFFC67EF2));
    final endColor = HSVColor.fromColor(const Color(0xFF5CA2E8));
    final color = HSVColor.lerp(startColor, endColor, t) ?? HSVColor.fromColor(Colors.white);
    return color.toColor();
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
