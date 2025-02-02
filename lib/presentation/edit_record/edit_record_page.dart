import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui/ui.dart';

import '../../model/exam.dart';
import '../../model/exam_record.dart';
import '../../model/problem.dart';
import '../../repository/exam_record/exam_record_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/duration_extension.dart';
import '../../util/injection.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../common/dialog.dart';
import '../common/progress_overlay.dart';
import '../common/review_problem_card.dart';
import '../home/record_list/cubit/record_list_cubit.dart';
import '../record_detail/record_detail_page.dart';
import 'edit_review_problem_dialog.dart';
import 'outlined_text_field.dart';

class EditRecordPage extends StatefulWidget {
  static const routeName = '/edit_record';
  final EditRecordPageArguments arguments;

  const EditRecordPage({
    super.key,
    required this.arguments,
  });

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final ExamRecordRepository _recordRepository = getIt.get();
  final AppCubit _appCubit = getIt.get();
  final RecordListCubit _recordListCubit = getIt.get();

  late final List<Exam> _exams = _appCubit.state.getAllExams();

  String title = '';
  final TextEditingController _examDurationEditingController =
      TextEditingController();
  final TextEditingController _scoreEditingController = TextEditingController();
  final TextEditingController _gradeEditingController = TextEditingController();
  final TextEditingController _percentileEditingController =
      TextEditingController();
  final TextEditingController _standardScoreEditingController =
      TextEditingController();
  final TextEditingController _feedbackEditingController =
      TextEditingController();

  final List<WrongProblem> _wrongProblems = [];
  final List<ReviewProblem> _reviewProblems = [];

  late Exam _selectedExam = _exams.first;
  DateTime _examStartedTime = DateTime.now();
  bool _isEditingMode = false;
  bool _isSaving = false;

  late final List<ExamRecord> _autocompleteRecords = (LinkedHashSet<ExamRecord>(
    equals: (a, b) => a.title == b.title,
    hashCode: (a) => a.title.hashCode,
  )..addAll(_recordListCubit.state.originalRecords))
      .toList();

  Map<String, dynamic> get _defaultLogProperties => {
        'exam_name': _selectedExam.name,
        'exam_id': _selectedExam.id,
        'subject': _selectedExam.subject.name,
        'is_editing_mode': _isEditingMode,
        'input_exam_existed': widget.arguments.inputExam != null,
      };

  @override
  void initState() {
    if (_appCubit.state.isNotSignedIn) {
      Navigator.pop(context);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfRecordLimitExceeded();
    });

    _onSelectedExamChanged(null);
    final recordToEdit = widget.arguments.recordToEdit;
    if (recordToEdit == null) {
      _isEditingMode = false;
      _initializeCreateMode();
    } else {
      _isEditingMode = true;
      _initializeEditMode(recordToEdit);
    }

    AnalyticsManager.eventStartTime(name: '[EditExamRecordPage] Edit finished');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    AnalyticsManager.logEvent(
      name: '[EditExamRecordPage] Edit finished',
      properties: _defaultLogProperties,
    );
  }

  void _initializeCreateMode() {
    final exam = widget.arguments.inputExam;
    _selectedExam = exam ?? _selectedExam;

    _feedbackEditingController.text = widget.arguments.prefillFeedback ?? '';

    final examStartedTime = widget.arguments.examStartedTime;
    _examStartedTime = examStartedTime ?? _examStartedTime;

    final examFinishedTime = widget.arguments.examFinishedTime;

    if (examStartedTime != null && examFinishedTime != null) {
      _examDurationEditingController.text = examFinishedTime
          .difference(_examStartedTime)
          .inMinutesWithCorrection
          .toString();
    } else if (exam != null) {
      _examDurationEditingController.text = exam.durationMinutes.toString();
    }
  }

  void _initializeEditMode(ExamRecord recordToEdit) {
    title = recordToEdit.title.replaceFirst(ExamRecord.autoSaveTitlePrefix, '');
    _selectedExam = recordToEdit.exam;
    _examStartedTime = recordToEdit.examStartedTime;
    _scoreEditingController.text = recordToEdit.score?.toString() ?? '';
    _gradeEditingController.text = recordToEdit.grade?.toString() ?? '';
    _percentileEditingController.text =
        recordToEdit.percentile?.toString() ?? '';
    _standardScoreEditingController.text =
        recordToEdit.standardScore?.toString() ?? '';
    _examDurationEditingController.text =
        recordToEdit.examDurationMinutes?.toString() ?? '';
    _wrongProblems.addAll(recordToEdit.wrongProblems);
    _feedbackEditingController.text = recordToEdit.feedback;
    _reviewProblems.addAll(recordToEdit.reviewProblems);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: AnnotatedRegion(
          value: defaultSystemUiOverlayStyle,
          child: Scaffold(
            body: ProgressOverlay(
              isProgressing: _isSaving,
              description: '저장할 문제 사진이 많으면 오래 걸릴 수 있습니다.',
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          child: _buildForm(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade100,
                ),
              ),
            ),
            child: _buildBottomButtons(),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 28),
          FormItem(
            label: '모의고사 이름',
            isRequired: true,
            child: CustomAutocomplete(
              initialValue: TextEditingValue(text: title),
              displayStringForOption: (option) => option.title,
              optionsBuilder: (textEditingValue) {
                return _autocompleteRecords.where((element) {
                  return element.title.contains(textEditingValue.text);
                }).toList();
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return FormTextField(
                  name: 'title',
                  hintText: '실감 모의고사 시즌1 1회',
                  textInputAction: TextInputAction.next,
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (_) => onFieldSubmitted(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          FormItem(
            label: '과목',
            child: FormDropdown(
              name: 'exam',
              initialValue: _selectedExam,
              onChanged: _onSelectedExamChanged,
              items: _exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(
                    exam.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 20,
            children: [
              FormItem(
                label: '점수',
                child: FormTextField(
                  name: 'score',
                  suffixText: '점',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                ),
              ),
              FormItem(
                label: '등급',
                child: FormTextField(
                  name: 'grade',
                  suffixText: '등급',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                ),
              ),
              FormItem(
                label: '백분위',
                child: FormTextField(
                  name: 'percentile',
                  suffixText: '%',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                ),
              ),
              FormItem(
                label: '표준점수',
                child: FormTextField(
                  name: 'standardScore',
                  suffixText: '점',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 20,
            children: [
              FormItem(
                label: '응시 일자',
                child: FormDatePicker(
                  name: 'examStartedDate',
                  initialValue: _examStartedTime,
                  firstDate:
                      _examStartedTime.subtract(const Duration(days: 365 * 20)),
                  lastDate: _examStartedTime.add(const Duration(days: 365)),
                  autoWidth: true,
                ),
              ),
              FormItem(
                label: '응시 시작 시각',
                child: FormTimePicker(
                  name: 'examStartedTime',
                  initialValue: TimeOfDay.fromDateTime(_examStartedTime),
                  autoWidth: true,
                ),
              ),
              FormItem(
                label: '응시 시간',
                child: FormTextField(
                  name: 'examDuration',
                  suffixText: '분',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FormItem(
            label: '틀린 문제',
            child: FormNumbersField(
              name: 'wrongProblems',
              initialValue: _wrongProblems.map((e) => e.problemNumber).toList(),
              hintText: '번호 입력',
              maxDigits: _selectedExam.numberOfQuestions.toString().length,
              displayStringForNumber: (number) => '$number번',
            ),
          ),
          const SizedBox(height: 20),
          _buildSubTitle('피드백'),
          const SizedBox(height: 8),
          TextField(
            controller: _feedbackEditingController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 2,
            style: const TextStyle(height: 1.2),
            decoration: InputDecoration(
              hintText:
                  '시험 운영은 계획한 대로 되었는지, 준비한 전략들은 잘 해냈는지, 새로 알게 된 문제점은 없었는지 생각해 보세요.',
              hintMaxLines: 10,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w300,
              ),
              isCollapsed: true,
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSubTitle('복습할 문제'),
          const SizedBox(height: 2),
          GridView.extent(
            padding: const EdgeInsets.symmetric(vertical: 8),
            maxCrossAxisExtent: 400,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final problem in _reviewProblems)
                ReviewProblemCard(
                  problem: problem,
                  onTap: () => _onReviewProblemCardTapped(problem),
                ),
              _buildReviewProblemAddCard(),
            ],
          ),
          const SizedBox(height: 68),
        ],
      ),
    );
  }

  Widget _buildSubTitle(
    String text, {
    bool isRequired = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildNumberInputWithTitle(
    TextEditingController controller,
    String title,
    String suffix,
    double width, {
    int? maxLength,
  }) {
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
            maxLength: maxLength,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewProblemAddCard() {
    return GestureDetector(
      onTap: _onReviewProblemAddCardTapped,
      child: Card(
        margin: const EdgeInsets.all(0),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/add.svg',
              width: 36,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade800,
                BlendMode.srcIn,
              ),
            ),
            Text(
              '추가하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w100,
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
              foregroundColor: Colors.grey,
            ),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: _onSavePressed,
            style: TextButton.styleFrom(
              foregroundColor:
                  title.isEmpty ? Colors.grey : Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isEditingMode ? '수정' : '저장',
              style: TextStyle(
                color: title.isEmpty ? Colors.grey.shade600 : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _checkIfRecordLimitExceeded() {
    final examRecordLimit = _appCubit.state.productBenefit.examRecordLimit;
    final examRecordCount = _recordListCubit.state.originalRecords.length;
    if (examRecordLimit != -1 &&
        (_isEditingMode
            ? examRecordCount > examRecordLimit
            : examRecordCount >= examRecordLimit)) {
      Navigator.pop(context);
      showExamRecordLimitInfoDialog(context);
    }
  }

  void _onTitleChanged(String text) {
    setState(() {
      title = text;
    });
  }

  void _onSelectedExamChanged(Exam? newExam) {
    setState(() {
      _selectedExam = newExam ?? _exams.first;
      _examDurationEditingController.text =
          _selectedExam.durationMinutes.toString();
    });
  }

  void _onExamStartedDateTextTapped() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _examStartedTime,
      firstDate: _examStartedTime.subtract(const Duration(days: 4000)),
      lastDate: _examStartedTime.add(const Duration(days: 365)),
      locale: const Locale('ko'),
    );
    if (date == null) return;
    setState(() {
      _examStartedTime = _examStartedTime.copyWith(
        year: date.year,
        month: date.month,
        day: date.day,
      );
    });
  }

  void _onExamStartedTimeTextTapped() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_examStartedTime),
    );
    if (time == null) return;
    setState(() {
      _examStartedTime = DateTime(
        _examStartedTime.year,
        _examStartedTime.month,
        _examStartedTime.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _onReviewProblemCardTapped(ReviewProblem problem) {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'review_problem_view_dialog'),
      builder: (context) {
        return EditReviewProblemDialog.edit(ReviewProblemEditModeParams(
          onReviewProblemEdited: _onReviewProblemEdited,
          onReviewProblemDeleted: _onReviewProblemDeleted,
          initialData: problem,
        ));
      },
    );
  }

  void _onReviewProblemEdited(
      ReviewProblem oldProblem, ReviewProblem newProblem) {
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
      routeSettings: const RouteSettings(name: 'review_problem_add_dialog'),
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
    Navigator.maybePop(context);
    AnalyticsManager.logEvent(
      name: '[EditExamRecordPage] Cancel button tapped',
      properties: _defaultLogProperties,
    );
  }

  void _onSavePressed() async {
    _checkIfRecordLimitExceeded();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모의고사 이름을 입력해주세요.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    await _saveRecord();
  }

  Future<ExamRecord?> _saveRecord() async {
    if (_isSaving) return null;
    setState(() {
      _isSaving = true;
    });

    final userId = _appCubit.state.me!.id;
    ExamRecord record = ExamRecord.create(
      userId: userId,
      title: title,
      exam: _selectedExam,
      examStartedTime: _examStartedTime,
      examDurationMinutes:
          _acceptPositiveInteger(_examDurationEditingController.text),
      score: _acceptPositiveInteger(_scoreEditingController.text),
      grade: _acceptPositiveInteger(_gradeEditingController.text),
      percentile: _acceptPositiveInteger(_percentileEditingController.text),
      standardScore:
          _acceptPositiveInteger(_standardScoreEditingController.text),
      wrongProblems: _wrongProblems,
      feedback: _feedbackEditingController.text,
      reviewProblems: _reviewProblems,
    );

    if (!_appCubit.state.productBenefit.isCustomExamAvailable &&
        record.exam.isCustomExam) {
      showCustomExamNotAvailableDialog(context);
      setState(() {
        _isSaving = false;
      });
      return null;
    }

    if (_isEditingMode) {
      final oldRecord = widget.arguments.recordToEdit!;
      record = await _recordRepository.updateExamRecord(
        oldRecord: oldRecord,
        newRecord: record.copyWith(
          id: oldRecord.id,
          createdAt: oldRecord.createdAt,
        ),
      );
      _recordListCubit.onRecordUpdated(record);
      if (mounted) Navigator.pop(context);
    } else {
      record = await _recordRepository.addExamRecord(record);
      _recordListCubit.onRecordCreated(record);
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          RecordDetailPage.routeName,
          arguments: RecordDetailPageArguments(recordId: record.id),
          result: record,
        );
      }
    }

    AnalyticsManager.logEvent(
      name: '[EditExamRecordPage] Exam record saved',
      properties: _defaultLogProperties,
    );

    return record;
  }

  void _onPopInvokedWithResult(bool didPop, _) {
    if (didPop) return;

    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: '${EditRecordPage.routeName}/exit_confirm_dialog',
      ),
      builder: (context) {
        return CustomAlertDialog(
          title: '아직 저장하지 않았어요!',
          content: '저장하지 않고 나가시겠어요?',
          actions: [
            CustomTextButton.secondary(
              text: '취소',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CustomTextButton.destructive(
              text: '저장하지 않고 나가기',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  int? _acceptPositiveInteger(String text) {
    final intValue = int.tryParse(text);
    if (intValue == null || intValue <= 0) return null;
    return intValue;
  }
}

class EditRecordPageArguments {
  final Exam? inputExam;
  final DateTime? examStartedTime;
  final DateTime? examFinishedTime;
  final ExamRecord? recordToEdit;
  final String? prefillFeedback;

  EditRecordPageArguments({
    this.inputExam,
    this.examStartedTime,
    this.examFinishedTime,
    this.recordToEdit,
    this.prefillFeedback,
  });
}
