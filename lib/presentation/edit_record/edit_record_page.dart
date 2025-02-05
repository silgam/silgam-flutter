import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
import '../home/record_list/cubit/record_list_cubit.dart';
import '../record_detail/record_detail_page.dart';
import 'widgets/form_review_problems_field.dart';

class EditRecordPageArguments {
  EditRecordPageArguments({
    this.recordToEdit,
    this.inputExam,
    this.prefillFeedback,
    this.examStartedTime,
    this.examFinishedTime,
  });

  final ExamRecord? recordToEdit;
  final Exam? inputExam;
  final String? prefillFeedback;
  final DateTime? examStartedTime;
  final DateTime? examFinishedTime;
}

class EditRecordPage extends StatefulWidget {
  EditRecordPage({
    super.key,
    this.recordToEdit,
    this.inputExam,
    this.prefillFeedback,
    this.examStartedTime,
    this.examFinishedTime,
  }) : examDurationMinutes = examStartedTime != null && examFinishedTime != null
            ? examFinishedTime
                .difference(examStartedTime)
                .inMinutesWithCorrection
            : null;

  static const routeName = '/edit_record';

  final ExamRecord? recordToEdit;
  final Exam? inputExam;
  final String? prefillFeedback;
  final DateTime? examStartedTime;
  final DateTime? examFinishedTime;
  final int? examDurationMinutes;

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final ExamRecordRepository _recordRepository = getIt.get();
  final AppCubit _appCubit = getIt.get();
  final RecordListCubit _recordListCubit = getIt.get();

  late final List<Exam> _exams = _appCubit.state.getAllExams();

  final GlobalKey<FormBuilderState> _formKey = GlobalKey();

  final String _titleFieldName = 'title';
  final String _examFieldName = 'exam';
  final String _scoreFieldName = 'score';
  final String _gradeFieldName = 'grade';
  final String _percentileFieldName = 'percentile';
  final String _standardScoreFieldName = 'standardScore';
  final String _examStartedDateFieldName = 'examStartedDate';
  final String _examStartedTimeFieldName = 'examStartedTime';
  final String _examDurationMinutesFieldName = 'examDurationMinutes';
  final String _wrongProblemsFieldName = 'wrongProblems';
  final String _feedbackFieldName = 'feedback';
  final String _reviewProblemsFieldName = 'reviewProblems';

  late final ExamRecord? _recordToEdit = widget.recordToEdit;

  late final String? _initialTitle =
      _recordToEdit?.title.replaceFirst(ExamRecord.autoSaveTitlePrefix, '');
  late final Exam _initialExam =
      _recordToEdit?.exam ?? widget.inputExam ?? _exams.first;
  late final int? _initialScore = _recordToEdit?.score;
  late final int? _initialGrade = _recordToEdit?.grade;
  late final int? _initialPercentile = _recordToEdit?.percentile;
  late final int? _initialStandardScore = _recordToEdit?.standardScore;
  late final DateTime _initialExamStartedDate =
      _recordToEdit?.examStartedTime ??
          widget.examStartedTime ??
          DateTime.now();
  late final TimeOfDay _initialExamStartedTime =
      TimeOfDay.fromDateTime(_initialExamStartedDate);
  late final int _initialExamDurationMinutes =
      _recordToEdit?.examDurationMinutes ??
          widget.examDurationMinutes ??
          _initialExam.durationMinutes;
  late final List<WrongProblem> _initialWrongProblems =
      _recordToEdit?.wrongProblems ?? [];
  late final String? _initialFeedback =
      _recordToEdit?.feedback ?? widget.prefillFeedback;
  late final List<ReviewProblem> _initialReviewProblems =
      _recordToEdit?.reviewProblems ?? [];

  late final bool _isEditingMode = _recordToEdit != null;
  bool _isSaving = false;
  late Exam _previousExam = _initialExam;
  late int _wrongProblemMaxDigits =
      _initialExam.numberOfQuestions.toString().length;
  bool _isChanged = false;

  late final List<ExamRecord> _autocompleteRecords = (LinkedHashSet<ExamRecord>(
    equals: (a, b) => a.title == b.title,
    hashCode: (a) => a.title.hashCode,
  )..addAll(_recordListCubit.state.originalRecords))
      .toList();

  @override
  void initState() {
    super.initState();

    AnalyticsManager.eventStartTime(name: '[EditExamRecordPage] Edit finished');

    if (_appCubit.state.isNotSignedIn) {
      Navigator.pop(context);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfRecordLimitExceeded();
    });
  }

  @override
  void dispose() {
    _logEvent('[EditExamRecordPage] Edit finished');

    super.dispose();
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

  void _logEvent(String name) {
    final Exam? exam = _formKey.currentState?.fields[_examFieldName]?.value;

    AnalyticsManager.logEvent(
      name: name,
      properties: {
        if (exam != null) ...{
          'exam_name': exam.name,
          'exam_id': exam.id,
          'subject': exam.subject.name,
        },
        'is_editing_mode': _isEditingMode,
        'input_exam_existed': widget.inputExam != null,
      },
    );
  }

  void _onExamChanged(Exam? exam) {
    if (exam == null) return;

    final examDurationMinutesField =
        _formKey.currentState?.fields[_examDurationMinutesFieldName];
    if (_previousExam.durationMinutes ==
        int.tryParse(examDurationMinutesField?.value)) {
      examDurationMinutesField?.didChange(exam.durationMinutes.toString());
    }

    _previousExam = exam;

    setState(() {
      _wrongProblemMaxDigits = exam.numberOfQuestions.toString().length;
    });
  }

  void _onCancelPressed() {
    Navigator.maybePop(context);
    _logEvent('[EditExamRecordPage] Cancel button tapped');
  }

  void _onSavePressed() async {
    if (_isSaving) return;

    _checkIfRecordLimitExceeded();

    final isFormValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isFormValid) {
      final firstErrorMessage =
          _formKey.currentState?.errors.entries.first.value;
      if (firstErrorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            content: Text(firstErrorMessage),
          ),
        );
      }
      return;
    }

    final String? userId = _appCubit.state.me?.id;
    final Map<String, dynamic>? values = _formKey.currentState?.value;
    if (userId == null || values == null) return;

    final Exam exam = values[_examFieldName];
    if (!_appCubit.state.productBenefit.isCustomExamAvailable &&
        exam.isCustomExam) {
      showCustomExamNotAvailableDialog(context);
      return;
    }

    final DateTime examStartedDate = values[_examStartedDateFieldName];
    final TimeOfDay examStartedTime = values[_examStartedTimeFieldName];
    final List<int> wrongProblemNumbers = values[_wrongProblemsFieldName];

    ExamRecord record = ExamRecord.create(
      userId: userId,
      title: values[_titleFieldName],
      exam: exam,
      examStartedTime: DateTime(
        examStartedDate.year,
        examStartedDate.month,
        examStartedDate.day,
        examStartedTime.hour,
        examStartedTime.minute,
      ),
      examDurationMinutes: int.tryParse(values[_examDurationMinutesFieldName]),
      score: int.tryParse(values[_scoreFieldName]),
      grade: int.tryParse(values[_gradeFieldName]),
      percentile: int.tryParse(values[_percentileFieldName]),
      standardScore: int.tryParse(values[_standardScoreFieldName]),
      wrongProblems: wrongProblemNumbers.map(WrongProblem.new).toList(),
      feedback: values[_feedbackFieldName],
      reviewProblems: values[_reviewProblemsFieldName],
    );

    setState(() {
      _isSaving = true;
    });

    final oldRecord = widget.recordToEdit;
    if (oldRecord != null) {
      record = await _recordRepository.updateExamRecord(
        oldRecord: oldRecord,
        newRecord: record.copyWith(
          id: oldRecord.id,
          createdAt: oldRecord.createdAt,
        ),
      );
      _recordListCubit.onRecordUpdated(record);

      if (mounted) Navigator.pop(context);
      return;
    }

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

    _logEvent('[EditExamRecordPage] Exam record saved');
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

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      canPop: !_isChanged,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      onChanged: () {
        if (_isChanged) return;

        setState(() {
          _isChanged = true;
        });
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 28),
          FormItem(
            label: '모의고사 이름',
            isRequired: true,
            child: CustomAutocomplete(
              initialValue: TextEditingValue(text: _initialTitle ?? ''),
              displayStringForOption: (option) => option.title,
              optionsBuilder: (textEditingValue) {
                return _autocompleteRecords.where((element) {
                  return element.title.contains(textEditingValue.text);
                }).toList();
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return FormTextField(
                  name: _titleFieldName,
                  hintText: '실감 모의고사 시즌1 1회',
                  textInputAction: TextInputAction.next,
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (_) => onFieldSubmitted(),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: '모의고사 이름을 입력해주세요.'),
                    FormBuilderValidators.maxLength(100,
                        errorText: '100자 이하로 입력해주세요.'),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          FormItem(
            label: '과목',
            child: FormDropdown(
              name: _examFieldName,
              initialValue: _initialExam,
              onChanged: _onExamChanged,
              items: _exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(exam.name),
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
                  name: _scoreFieldName,
                  initialValue: _initialScore?.toString() ?? '',
                  hintText: '      ',
                  suffixText: '점',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(
                      errorText: '점수는 숫자만 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.min(
                      0,
                      errorText: '점수를 0 이상 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.max(
                      999,
                      errorText: '점수를 999 이하로 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                  ]),
                ),
              ),
              FormItem(
                label: '등급',
                child: FormTextField(
                  name: _gradeFieldName,
                  initialValue: _initialGrade?.toString() ?? '',
                  hintText: '   ',
                  suffixText: '등급',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(
                      errorText: '등급은 숫자만 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.min(
                      1,
                      errorText: '등급을 1 이상 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.max(
                      9,
                      errorText: '등급을 9 이하로 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                  ]),
                ),
              ),
              FormItem(
                label: '백분위',
                child: FormTextField(
                  name: _percentileFieldName,
                  initialValue: _initialPercentile?.toString() ?? '',
                  hintText: '      ',
                  suffixText: '%',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(
                      errorText: '백분위는 숫자만 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.min(
                      0,
                      errorText: '백분위를 0 이상 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.max(
                      100,
                      errorText: '백분위를 100 이하로 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                  ]),
                ),
              ),
              FormItem(
                label: '표준점수',
                child: FormTextField(
                  name: _standardScoreFieldName,
                  initialValue: _initialStandardScore?.toString() ?? '',
                  hintText: '      ',
                  suffixText: '점',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(
                      errorText: '표준점수는 숫자만 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.min(
                      0,
                      errorText: '표준점수를 0 이상 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.max(
                      200,
                      errorText: '표준점수를 200 이하로 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                  ]),
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
                  name: _examStartedDateFieldName,
                  initialValue: _initialExamStartedDate,
                  firstDate: _initialExamStartedDate
                      .subtract(const Duration(days: 365 * 20)),
                  lastDate:
                      _initialExamStartedDate.add(const Duration(days: 365)),
                  autoWidth: true,
                ),
              ),
              FormItem(
                label: '응시 시작 시각',
                child: FormTimePicker(
                  name: _examStartedTimeFieldName,
                  initialValue: _initialExamStartedTime,
                  autoWidth: true,
                ),
              ),
              FormItem(
                label: '응시 시간',
                child: FormTextField(
                  name: _examDurationMinutesFieldName,
                  initialValue: _initialExamDurationMinutes.toString(),
                  hintText: '      ',
                  suffixText: '분',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  hideError: true,
                  autoWidth: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(
                      errorText: '응시 시간은 숫자만 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.min(
                      0,
                      errorText: '응시 시간을 0 이상 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                    FormBuilderValidators.max(
                      999,
                      errorText: '응시 시간을 999 이하로 입력해주세요.',
                      checkNullOrEmpty: false,
                    ),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FormItem(
            label: '틀린 문제',
            child: FormNumbersField(
              name: _wrongProblemsFieldName,
              initialValue:
                  _initialWrongProblems.map((e) => e.problemNumber).toList(),
              hintText: '번호 입력',
              maxDigits: _wrongProblemMaxDigits,
              displayStringForNumber: (number) => '$number번',
            ),
          ),
          const SizedBox(height: 20),
          FormItem(
            label: '피드백',
            child: FormTextField(
              name: _feedbackFieldName,
              initialValue: _initialFeedback,
              hintText:
                  '시험 운영은 계획한 대로 되었는지, 준비한 전략들은 잘 해냈는지, 새로 알게 된 문제점은 없었는지 생각해 보세요.',
              minLines: 2,
              maxLines: null,
            ),
          ),
          const SizedBox(height: 20),
          FormItem(
            label: '복습할 문제',
            child: FormReviewProblemsField(
              name: _reviewProblemsFieldName,
              initialValue: _initialReviewProblems,
            ),
          ),
          const SizedBox(height: 68),
        ],
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isEditingMode ? '수정' : '저장',
            ),
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}
