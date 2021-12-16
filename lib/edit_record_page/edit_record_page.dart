import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../model/exam.dart';
import '../model/exam_record.dart';
import '../model/problem.dart';
import '../model/subject.dart';
import '../repository/exam_record_repository.dart';
import '../repository/user_repository.dart';
import 'continuous_number_field.dart';
import 'edit_review_problem_dialog.dart';
import 'outlined_text_field.dart';

class EditRecordPage extends StatefulWidget {
  static const routeName = '/edit_record';
  final EditRecordPageArguments arguments;

  const EditRecordPage({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _examDurationEditingController = TextEditingController();
  final TextEditingController _scoreEditingController = TextEditingController();
  final TextEditingController _gradeEditingController = TextEditingController();
  final TextEditingController _feedbackEditingController = TextEditingController();
  final List<WrongProblem> _wrongProblems = [];
  final List<ReviewProblem> _reviewProblems = [];
  Subject _selectedSubject = Subject.language;
  DateTime _examStartedTime = DateTime.now();
  bool _isTitleEmpty = true;

  final UserRepository userRepository = UserRepository();
  final ExamRecordRepository recordRepository = ExamRecordRepository();

  @override
  void initState() {
    final exam = widget.arguments.inputExam;
    if (exam != null) {
      _examDurationEditingController.text = exam.examDuration.toString();
      _selectedSubject = exam.subject;
    }

    final examStartedTime = widget.arguments.examStartedTime;
    if (examStartedTime != null) {
      _examStartedTime = examStartedTime;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: _buildForm(),
          ),
        ),
        const Divider(height: 1),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        _buildSubTitle('모의고사 기록하기'),
        TextField(
          controller: _titleEditingController,
          onChanged: _onTitleChanged,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration.collapsed(
            hintText: '모의고사 이름',
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 16),
        _buildSubTitle('과목'),
        const SizedBox(height: 2),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            value: _selectedSubject,
            onChanged: _onSelectedSubjectChanged,
            items: Subject.values.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Text(subject.subjectName),
              );
            }).toList(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildSubTitle('시험 시작 시각'),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: _onExamStartedTimeTextTapped,
          child: Text(
            DateFormat.yMEd('ko_KR').add_Hm().format(_examStartedTime),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Wrap(
          spacing: 24,
          children: [
            _buildNumberInputWithTitle(_examDurationEditingController, '시험 시간', '분', 60),
            _buildNumberInputWithTitle(_scoreEditingController, '점수', '점', 60),
            _buildNumberInputWithTitle(_gradeEditingController, '등급', '등급', 56),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildSubTitle('틀린 문제'),
        Wrap(
          spacing: 8,
          runSpacing: -8,
          children: [
            for (final problem in _wrongProblems)
              Chip(
                label: Text('${problem.problemNumber}번'),
                onDeleted: () => _onWrongProblemChipDeleted(problem),
                labelPadding: const EdgeInsets.only(left: 8, right: 2),
                deleteIconColor: Colors.white54,
                backgroundColor: Theme.of(context).primaryColor,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  height: 1.21,
                ),
              ),
            SizedBox(
              width: 80,
              child: ContinuousNumberField(
                onSubmit: _onWrongProblemAdded,
                onDelete: _onWrongProblemDeleted,
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildSubTitle('피드백'),
        const SizedBox(height: 8),
        TextField(
          controller: _feedbackEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 2,
          decoration: const InputDecoration(
            isCollapsed: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildSubTitle('복습할 문제'),
        const SizedBox(height: 2),
        GridView.extent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final problem in _reviewProblems) _buildReviewProblemCard(problem),
            _buildReviewProblemAddCard(),
          ],
        )
      ],
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildNumberInputWithTitle(
    TextEditingController controller,
    String title,
    String suffix,
    double width,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubTitle(title),
        const SizedBox(height: 6),
        SizedBox(
          width: width,
          child: OutlinedTextField(
            controller: controller,
            suffix: suffix,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewProblemCard(ReviewProblem problem) {
    return GestureDetector(
      onTap: () => _onReviewProblemCardTapped(problem),
      child: Card(
        margin: const EdgeInsets.all(4),
        elevation: 0,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Stack(
          children: [
            if (problem.imagePaths.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.file(
                  File(problem.imagePaths.first),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            if (problem.imagePaths.isEmpty)
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/app_icon/app_icon_transparent.png',
                  width: 100,
                  color: Colors.grey.shade100,
                ),
              ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                color: Colors.white.withAlpha(200),
              ),
              child: Text(
                problem.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewProblemAddCard() {
    return GestureDetector(
      onTap: _onReviewProblemAddCardTapped,
      child: Card(
        margin: const EdgeInsets.all(4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/add.svg',
              width: 36,
              color: Colors.grey.shade800,
            ),
            const SizedBox(width: 2),
            Text(
              '추가하기',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w100,
                height: 1.2,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _onCancelPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('취소'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: _isTitleEmpty ? null : _onSavePressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '저장',
              style: TextStyle(
                color: _isTitleEmpty ? Colors.grey.shade600 : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTitleChanged(String title) {
    if (_isTitleEmpty && _titleEditingController.text.isNotEmpty) {
      setState(() {
        _isTitleEmpty = false;
      });
      return;
    }
    if (!_isTitleEmpty && _titleEditingController.text.isEmpty) {
      setState(() {
        _isTitleEmpty = true;
      });
      return;
    }
  }

  void _onSelectedSubjectChanged(Subject? newSubject) {
    setState(() {
      _selectedSubject = newSubject ?? Subject.language;
    });
  }

  void _onExamStartedTimeTextTapped() async {
    final dateTime = await DatePicker.showDateTimePicker(
      context,
      locale: LocaleType.ko,
      currentTime: _examStartedTime,
    );
    if (dateTime == null) return;
    setState(() {
      _examStartedTime = dateTime;
    });
  }

  void _onWrongProblemChipDeleted(WrongProblem problem) {
    setState(() {
      _wrongProblems.remove(problem);
    });
  }

  void _onWrongProblemAdded(int problemNumber) {
    if (_wrongProblems.where((problem) {
      return problem.problemNumber == problemNumber;
    }).isNotEmpty) return;

    setState(() {
      _wrongProblems.add(WrongProblem(problemNumber));
    });
  }

  void _onWrongProblemDeleted() {
    setState(() {
      _wrongProblems.removeLast();
    });
  }

  void _onReviewProblemCardTapped(ReviewProblem problem) {
    showDialog(
      context: context,
      builder: (context) {
        return EditReviewProblemDialog.edit(ReviewProblemEditModeParams(
          onReviewProblemEdited: _onReviewProblemEdited,
          onReviewProblemDeleted: _onReviewProblemDeleted,
          initialData: problem,
        ));
      },
    );
  }

  void _onReviewProblemEdited(ReviewProblem oldProblem, ReviewProblem newProblem) {
    final oldProblemIndex = _reviewProblems.indexOf(oldProblem);
    if (oldProblemIndex == -1) return;
    setState(() {
      _reviewProblems[oldProblemIndex] = newProblem;
    });
  }

  void _onReviewProblemDeleted(ReviewProblem deletedProblem) {
    setState(() {
      _reviewProblems.remove(deletedProblem);
    });
  }

  void _onReviewProblemAddCardTapped() {
    showDialog(
      context: context,
      builder: (context) {
        return EditReviewProblemDialog.add(ReviewProblemAddModeParams(
          onReviewProblemAdded: _onReviewProblemAdded,
        ));
      },
    );
  }

  void _onReviewProblemAdded(ReviewProblem problem) {
    setState(() {
      _reviewProblems.add(problem);
    });
  }

  void _onCancelPressed() {
    Navigator.pop(context);
  }

  void _onSavePressed() async {
    if (_isTitleEmpty) return;
    await saveRecord();
    Navigator.pop(context);
  }

  Future<void> saveRecord() async {
    final ExamRecord record = ExamRecord(
      userId: userRepository.getUser().uid,
      title: _titleEditingController.text,
      subject: _selectedSubject,
      examStartedTime: _examStartedTime,
      examDurationMinutes: int.tryParse(_examDurationEditingController.text),
      score: int.tryParse(_scoreEditingController.text),
      grade: int.tryParse(_gradeEditingController.text),
      wrongProblems: _wrongProblems,
      feedback: _feedbackEditingController.text,
      reviewProblems: _reviewProblems,
    );
    await recordRepository.addExamRecord(record);
  }
}

class EditRecordPageArguments {
  final Exam? inputExam;
  final DateTime? examStartedTime;

  EditRecordPageArguments({
    this.inputExam,
    this.examStartedTime,
  });
}
