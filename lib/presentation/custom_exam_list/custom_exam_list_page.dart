import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../model/exam.dart';
import '../app/cubit/app_cubit.dart';
import '../common/custom_menu_bar.dart';
import '../custom_exam_edit/custom_exam_edit_page.dart';

class CustomExamListPage extends StatefulWidget {
  static const routeName = '/custom_exam';

  const CustomExamListPage({super.key});

  @override
  State<CustomExamListPage> createState() => _CustomExamListPageState();
}

class _CustomExamListPageState extends State<CustomExamListPage> {
  void _onExamItemTab(Exam exam) {
    Navigator.pushNamed(context, CustomExamEditPage.routeName);
  }

  void _onAddExamButtonPressed() {
    Navigator.pushNamed(context, CustomExamEditPage.routeName);
  }

  void _onHelpButtonPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '제목', // TODO
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '설명', // TODO
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildExamInfoWidget(IconData iconData, String text) {
    return Row(
      children: [
        Icon(
          iconData,
          size: 16,
          color: Colors.grey.shade800,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 12,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomExamItem(Exam exam) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: InkWell(
        onTap: () => _onExamItemTab(exam),
        splashColor: Colors.transparent,
        child: Ink(
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        maxLines: 2,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
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
                      Icons.schedule,
                      '${DateFormat.Hm().format(exam.startTime)} ~ ${DateFormat.Hm().format(exam.endTime)} (${exam.durationMinutes}분)',
                    ),
                    const SizedBox(height: 2),
                    _buildExamInfoWidget(
                      Icons.text_snippet_outlined,
                      '${exam.numberOfQuestions}문제 / ${exam.perfectScore}점',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddExamButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: InkWell(
        onTap: _onAddExamButtonPressed,
        splashColor: Colors.transparent,
        child: Ink(
          color: Colors.white,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: 4),
                Text(
                  '과목 만들기',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomMenuBar(
              title: '나만의 과목 만들기',
              actionButtons: [
                ActionButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: '도움말',
                  onPressed: _onHelpButtonPressed,
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<AppCubit, AppState>(
                buildWhen: (previous, current) =>
                    listEquals(previous.customExams, current.customExams),
                builder: (context, state) {
                  return ListView(
                    children: [
                      ...state.customExams.map(_buildCustomExamItem),
                      _buildAddExamButton(),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddExamButtonPressed,
        tooltip: '과목 만들기',
        child: const Icon(Icons.add),
      ),
    );
  }
}
