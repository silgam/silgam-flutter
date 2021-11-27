import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/exam.dart';

class TakeExamView extends StatelessWidget {
  final int gradientStartColor = 0xFF3548D8;
  final int gradientEndColor = 0xFF7D3DD5;

  const TakeExamView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ListView.builder(
        itemCount: defaultExams.length,
        itemBuilder: (context, i) => _buildExamItem(context, i, defaultExams),
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
      ),
    );
  }

  Widget _buildExamItem(BuildContext context, int i, List<Exam> items) {
    final thisExam = items[i];
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      margin: const EdgeInsets.only(left: 28, right: 28, bottom: 20),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getGradientColor(i / (items.length - 1)),
              _getGradientColor((i + 1) / (items.length - 1)),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _getGradientColor((i + 1) / (items.length - 1)).withAlpha(120),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              thisExam.subjectName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _TextWithIcon(
              icon: Icons.schedule,
              text: thisExam.buildExamTimeString(),
            ),
            const SizedBox(height: 10),
            _TextWithIcon(
                icon: Icons.text_snippet,
                text: '${thisExam.numberOfQuestions}문제 / ${thisExam.perfectScore}점'),
          ],
        ),
      ),
    );
  }

  Color _getGradientColor(double t) {
    final startColor = HSVColor.fromColor(Color(gradientStartColor));
    final endColor = HSVColor.fromColor(Color(gradientEndColor));
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
