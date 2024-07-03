import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import '../../model/exam.dart';
import '../../repository/exam/exam_repository.dart';
import '../../repository/exam_record/exam_record_repository.dart';
import '../../util/date_time_extension.dart';
import '../../util/injection.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../common/dialog.dart';
import '../custom_exam_list/custom_exam_list_page.dart';
import 'cubit/custom_exam_edit_cubit.dart';

const int _maxCustomExams = 100;

class CustomExamEditPage extends StatefulWidget {
  static const routeName = '${CustomExamListPage.routeName}/edit';

  final Exam? examToEdit;

  const CustomExamEditPage({
    super.key,
    this.examToEdit,
  });

  @override
  State<CustomExamEditPage> createState() => _CustomExamEditPageState();
}

class _CustomExamEditPageState extends State<CustomExamEditPage> {
  static const _examNameFieldName = 'examName';
  static const _baseExamFieldName = 'baseExam';
  static const _startTimeFieldName = 'startTime';
  static const _durationFieldName = 'duration';
  static const _numberOfQuestionsFieldName = 'numberOfQuestions';
  static const _perfectScoreFieldName = 'perfectScore';

  final ExamRepository _examRepository = getIt.get();
  final ExamRecordRepository _examRecordRepository = getIt.get();
  final CustomExamEditCubit _customExamEditCubit = getIt.get();
  final AppCubit _appCubit = getIt.get();
  late final List<Exam> _defaultExams = _appCubit.state.getDefaultExams();

  late final Exam? _examToEdit = widget.examToEdit;
  late final bool _isEditMode = _examToEdit != null;

  late final _examNameInitialValue = _examToEdit?.name;
  late final _baseExamInitialValue = _examToEdit == null
      ? _defaultExams.first
      : _defaultExams.firstWhere((exam) => exam.subject == _examToEdit.subject);
  late final _startTimeInitialValue = _examToEdit == null
      ? TimeOfDay.fromDateTime(_baseExamInitialValue.startTime)
      : TimeOfDay.fromDateTime(_examToEdit.startTime);
  late final _durationInitialValue = _examToEdit?.durationMinutes.toString() ??
      _baseExamInitialValue.durationMinutes.toString();
  late final _numberOfQuestionsInitialValue =
      _examToEdit?.numberOfQuestions.toString() ??
          _baseExamInitialValue.numberOfQuestions.toString();
  late final _perfectScoreInitialValue = _examToEdit?.perfectScore.toString() ??
      _baseExamInitialValue.perfectScore.toString();

  final _formKey = GlobalKey<FormBuilderState>();
  bool _isChanged = false;

  late final defaultInputDecoration = InputDecoration(
    hintStyle: TextStyle(color: Colors.grey.shade500),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(12),
    isCollapsed: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
      borderRadius: const BorderRadius.all(Radius.circular(6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
      borderRadius: const BorderRadius.all(Radius.circular(6)),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Colors.red),
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Colors.red),
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
  );

  @override
  void initState() {
    super.initState();

    if (!_isEditMode && _appCubit.state.customExams.length == _maxCustomExams) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('과목은 최대 $_maxCustomExams개까지 만들 수 있습니다.'),
          ),
        );
        Navigator.pop(context);
      });
      return;
    }
  }

  void _onPopInvoked(bool didPop) {
    if (didPop) return;

    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: '${CustomExamEditPage.routeName}/exit_confirm_dialog',
      ),
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '아직 저장하지 않았어요!',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text('저장하지 않고 나가시겠어요?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('저장하지 않고 나가기'),
            ),
          ],
        );
      },
    );
  }

  void _onCancelButtonPressed() {
    Navigator.maybePop(context);
  }

  void _onSaveButtonPressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (!_appCubit.state.productBenefit.isCustomExamAvailable) {
        showCustomExamNotAvailableDialog(context);
        return;
      }

      final values = _formKey.currentState?.value;
      if (values == null) return;

      _customExamEditCubit.save(
        examToEdit: _examToEdit,
        examName: values[_examNameFieldName],
        baseExam: values[_baseExamFieldName],
        startTime: values[_startTimeFieldName],
        duration: int.parse(values[_durationFieldName]),
        numberOfQuestions: int.parse(values[_numberOfQuestionsFieldName]),
        perfectScore: int.parse(values[_perfectScoreFieldName]),
      );
      Navigator.pop(context, true);
    } else {
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
    }
  }

  void _deleteExam(Exam examToDelete) async {
    EasyLoading.show();

    final examRecordsUsing =
        await _examRecordRepository.getMyExamRecordsByExamId(
      _appCubit.state.me!.id,
      examToDelete.id,
    );

    if (examRecordsUsing.isEmpty) {
      _examRepository.deleteExam(examToDelete.id);
      if (mounted) Navigator.pop(context, true);
    } else {
      if (mounted) {
        final recordNames =
            examRecordsUsing.map((record) => '• ${record.title}').join('\n');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            title: const Text('과목을 삭제할 수 없어요!'),
            content: Text(
              '아래의 모의고사 기록들이 이 과목으로 설정되어 있어요. 이 기록들을 삭제하거나 다른 과목으로 바꾸면 이 과목을 삭제할 수 있어요.\n\n$recordNames',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }

    EasyLoading.dismiss();
  }

  void _onDeleteButtonPressed() async {
    final examToDelete = _examToEdit;
    if (examToDelete == null) return;

    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: '${CustomExamEditPage.routeName}/delete_confirm_dialog',
      ),
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '정말 이 과목을 삭제하실 건가요?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(examToDelete.name),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteExam(examToDelete);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _onDefaultExamChanged(Exam? exam) {
    if (exam == null) return;

    _formKey.currentState?.fields[_startTimeFieldName]
        ?.didChange(TimeOfDay.fromDateTime(exam.startTime));
    _formKey.currentState?.fields[_durationFieldName]
        ?.didChange(exam.durationMinutes.toString());
    _formKey.currentState?.fields[_numberOfQuestionsFieldName]
        ?.didChange(exam.numberOfQuestions.toString());
    _formKey.currentState?.fields[_perfectScoreFieldName]
        ?.didChange(exam.perfectScore.toString());
  }

  Widget _buildLabel(String text, {String? tooltip}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (tooltip != null) const SizedBox(width: 4),
          if (tooltip != null)
            Tooltip(
              message: tooltip,
              triggerMode: TooltipTriggerMode.tap,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              verticalOffset: 8,
              child: Icon(
                Icons.help_outline,
                color: Colors.grey.shade500,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldWithLabel({
    required String label,
    required Widget field,
    double? fieldWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          width: fieldWidth,
          child: field,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      canPop: !_isChanged,
      onPopInvoked: _onPopInvoked,
      onChanged: () {
        if (_isChanged) return;

        setState(() {
          _isChanged = true;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('과목 이름'),
          FormBuilderTextField(
            name: _examNameFieldName,
            initialValue: _examNameInitialValue,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '과목 이름을 입력해주세요.'),
              FormBuilderValidators.maxLength(20, errorText: '20자 이하로 입력해주세요.'),
            ]),
            decoration: defaultInputDecoration.copyWith(
              hintText: '실감 하프 모의고사',
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel(
            '기본 과목',
            tooltip: '시험 시뮬레이션에서 표시될 교시와 재생될 타종 소리의 기준이 되는 과목입니다.',
          ),
          FormBuilderDropdown<Exam>(
            name: _baseExamFieldName,
            initialValue: _baseExamInitialValue,
            items: _defaultExams
                .map((exam) => DropdownMenuItem(
                      value: exam,
                      child: Text(exam.name),
                    ))
                .toList(),
            decoration: defaultInputDecoration,
            onChanged: _onDefaultExamChanged,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFieldWithLabel(
                label: '시험 시작 시간',
                fieldWidth: 108,
                field: FormBuilderField<TimeOfDay>(
                  name: _startTimeFieldName,
                  initialValue: _startTimeInitialValue,
                  builder: (field) => GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: field.value ?? TimeOfDay.now(),
                      );
                      if (time == null) return;
                      field.didChange(time);
                    },
                    child: InputDecorator(
                      decoration: defaultInputDecoration,
                      child: Text(
                        DateFormat.jm('ko_KR').format(
                            field.value?.toDateTime() ?? DateTime.now()),
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildFieldWithLabel(
                label: '시험 시간',
                fieldWidth: 75,
                field: FormBuilderTextField(
                  name: _durationFieldName,
                  initialValue: _durationInitialValue,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: '시험 시간을 입력해주세요.'),
                    FormBuilderValidators.numeric(
                        errorText: '시험 시간은 숫자만 입력해주세요.'),
                    FormBuilderValidators.min(5,
                        errorText: '시험 시간을 5분 이상으로 입력해주세요.'),
                    FormBuilderValidators.max(300,
                        errorText: '시험 시간을 300분 이하로 입력해주세요.'),
                  ]),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: defaultInputDecoration.copyWith(
                    suffixText: '분',
                    errorStyle: const TextStyle(height: 0.001),
                  ),
                ),
              ),
              _buildFieldWithLabel(
                label: '문제 수',
                fieldWidth: 90,
                field: FormBuilderTextField(
                  name: _numberOfQuestionsFieldName,
                  initialValue: _numberOfQuestionsInitialValue,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: '문제 수를 입력해주세요.'),
                    FormBuilderValidators.numeric(
                        errorText: '문제 수는 숫자만 입력해주세요.'),
                    FormBuilderValidators.min(1,
                        errorText: '문제 수를 1 이상 입력해주세요.'),
                    FormBuilderValidators.max(300,
                        errorText: '문제 수를 300 이하로 입력해주세요.'),
                  ]),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: defaultInputDecoration.copyWith(
                    suffixText: '문제',
                    errorStyle: const TextStyle(height: 0.001),
                  ),
                ),
              ),
              _buildFieldWithLabel(
                label: '만점',
                fieldWidth: 75,
                field: FormBuilderTextField(
                  name: _perfectScoreFieldName,
                  initialValue: _perfectScoreInitialValue,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: '만점을 입력해주세요.'),
                    FormBuilderValidators.numeric(errorText: '만점은 숫자만 입력해주세요.'),
                    FormBuilderValidators.min(1, errorText: '만점을 1 이상 입력해주세요.'),
                    FormBuilderValidators.max(999,
                        errorText: '만점을 999 이하로 입력해주세요.'),
                  ]),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: defaultInputDecoration.copyWith(
                    suffixText: '점',
                    errorStyle: const TextStyle(height: 0.001),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _onCancelButtonPressed,
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
              onPressed: _onSaveButtonPressed,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(_isEditMode ? '수정' : '추가'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AnnotatedRegion(
        value: defaultSystemUiOverlayStyle,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        _isEditMode
                            ? Container(
                                alignment: Alignment.topRight,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: TextButton(
                                  onPressed: _onDeleteButtonPressed,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('삭제하기'),
                                ),
                              )
                            : const SizedBox(height: 28),
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: const TextScaler.linear(1.0),
                          ),
                          child: _buildForm(),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomExamEditPageArguments {
  final Exam? examToEdit;

  CustomExamEditPageArguments({
    required this.examToEdit,
  });
}
