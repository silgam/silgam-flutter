import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import '../../model/exam.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../common/dialog.dart';
import '../custom_exam_edit/custom_exam_edit_page.dart';
import '../custom_exam_guide/custom_exam_guide_page.dart';

class CustomExamListPage extends StatefulWidget {
  static const routeName = '/custom_exam';

  const CustomExamListPage({super.key});

  @override
  State<CustomExamListPage> createState() => _CustomExamListPageState();
}

class _CustomExamListPageState extends State<CustomExamListPage> {
  final AppCubit _appCubit = getIt.get();

  void _onExamItemTab(Exam exam) async {
    final isEdited = await Navigator.pushNamed(
      context,
      CustomExamEditPage.routeName,
      arguments: CustomExamEditPageArguments(
        examToEdit: exam,
      ),
    );
    if (isEdited == true) {
      await _appCubit.updateCustomExams();
    }
  }

  void _onAddExamButtonPressed() async {
    final isAdded =
        await Navigator.pushNamed(context, CustomExamEditPage.routeName);
    if (isAdded == true) {
      await _appCubit.updateCustomExams();
    }
  }

  void _onHelpButtonPressed() {
    if (_appCubit.state.productBenefit.isCustomExamAvailable) {
      Navigator.pushNamed(
        context,
        CustomExamGuidePage.routeName,
        arguments: const CustomExamGuideArguments(
          isFromCustomExamListPage: true,
        ),
      );
    } else {
      showCustomExamNotAvailableDialog(context, isFromCustomExamListPage: true);
    }
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

  Widget _buildCustomExamItem(Exam exam, List<Exam> defaultExams) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => _onExamItemTab(exam),
          splashColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        defaultExams
                            .firstWhere((defaultExam) =>
                                defaultExam.subject == exam.subject)
                            .name,
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
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: _onAddExamButtonPressed,
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.add,
                  size: 24,
                  color: Colors.grey.shade600,
                ),
                Text(
                  '과목 만들기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
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
    return PageLayout(
      title: '나만의 과목 만들기',
      onBackPressed: () => Navigator.of(context).pop(),
      appBarActions: [
        AppBarAction(
          iconData: Icons.help_outline,
          tooltip: '도움말',
          onPressed: _onHelpButtonPressed,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddExamButtonPressed,
        tooltip: '과목 만들기',
        child: const Icon(Icons.add),
      ),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) =>
            !listEquals(previous.customExams, current.customExams) ||
            !listEquals(previous.getDefaultExams(), current.getDefaultExams()),
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _appCubit.updateCustomExams,
            child: ListView(
              children: [
                ...state.customExams.map(
                  (exam) => _buildCustomExamItem(
                    exam,
                    state.getDefaultExams(),
                  ),
                ),
                _buildAddExamButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
