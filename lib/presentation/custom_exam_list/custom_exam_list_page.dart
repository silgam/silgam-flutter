import 'package:flutter/material.dart';

import '../../model/exam.dart';
import '../../repository/exam/exam_repository.dart';
import '../common/custom_menu_bar.dart';

class CustomExamListPage extends StatelessWidget {
  static const routeName = '/custom_exam';

  const CustomExamListPage({super.key});

  Widget _buildExamInfoWidget(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 12,
      ),
    );
  }

  Widget _buildCustomExamItem(Exam exam) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.subject.defaultExam.name,
                  style: TextStyle(
                    color: Color(exam.color),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exam.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildExamInfoWidget(
                  '${exam.startTime.hour}:${exam.startTime.minute} ~'),
              _buildExamInfoWidget('${exam.durationMinutes}분'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomMenuBar(
              title: '나만의 과목 만들기',
            ),
            Expanded(
              child: ListView(
                children: defaultExams.map(_buildCustomExamItem).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
