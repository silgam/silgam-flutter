import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/exam.dart';
import '../repository/exam_repository.dart';

class TakeExamView extends StatelessWidget {
  const TakeExamView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildExamItem(
            index,
            ExamRepository.defaultExams.length,
            ExamRepository.defaultExams[index],
          ),
          childCount: ExamRepository.defaultExams.length,
        ),
      ),
    );
  }

  Widget _buildExamItem(int index, int numberOfItems, Exam thisExam) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      margin: const EdgeInsets.only(left: 28, right: 28, bottom: 20),
      elevation: 0,
      child: _ExamCardContainer(index, numberOfItems, thisExam),
    );
  }
}

class _ExamCardContainer extends StatefulWidget {
  final int index;
  final int numberOfItems;
  final Exam thisExam;

  const _ExamCardContainer(this.index, this.numberOfItems, this.thisExam, {Key? key})
      : super(key: key);

  @override
  _ExamCardContainerState createState() => _ExamCardContainerState();
}

class _ExamCardContainerState extends State<_ExamCardContainer> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
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
              color:
                  _getGradientColor((widget.index + 1) / (widget.numberOfItems - 1)).withAlpha(120),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              widget.thisExam.subjectName,
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
                text: '${widget.thisExam.numberOfQuestions}문제 / ${widget.thisExam.perfectScore}점'),
          ],
        ),
      ),
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
