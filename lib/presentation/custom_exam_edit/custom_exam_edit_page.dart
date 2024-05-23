import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import '../../model/exam.dart';
import '../../repository/exam/exam_repository.dart';
import '../../util/date_time_extension.dart';
import '../custom_exam_list/custom_exam_list_page.dart';

class CustomExamEditPage extends StatefulWidget {
  static const routeName = '${CustomExamListPage.routeName}/edit';

  const CustomExamEditPage({super.key});

  @override
  State<CustomExamEditPage> createState() => _CustomExamEditPageState();
}

class _CustomExamEditPageState extends State<CustomExamEditPage> {
  static const _subjectNameFieldName = 'subjectName';
  static const _baseExamFieldName = 'baseExam';
  static const _startTimeFieldName = 'startTime';
  static const _durationFieldName = 'duration';
  static const _numberOfQuestionsFieldName = 'numberOfQuestions';
  static const _perfectScoreFieldName = 'perfectScore';

  final _baseExamInitialValue = defaultExams.first;
  late final _startTimeInitialValue =
      TimeOfDay.fromDateTime(_baseExamInitialValue.startTime);
  late final _durationInitialValue =
      _baseExamInitialValue.durationMinutes.toString();
  late final _numberOfQuestionsInitialValue =
      _baseExamInitialValue.numberOfQuestions.toString();
  late final _perfectScoreInitialValue =
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

  Future<bool> _onWillPop() async {
    if (!_isChanged) {
      return true;
    }

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
              child: Text(
                '취소',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('저장하지 않고 나가기'),
            ),
          ],
        );
      },
    );
    return false;
  }

  void _onCancelButtonPressed() {
    Navigator.maybePop(context);
  }

  void _onSaveButtonPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('valid')),
      );
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
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
      onWillPop: _onWillPop,
      onChanged: () {
        _isChanged = true;
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        children: [
          _buildLabel('과목 이름'),
          FormBuilderTextField(
            name: _subjectNameFieldName,
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
          _buildLabel('기본 과목'),
          FormBuilderDropdown<Exam>(
            name: _baseExamFieldName,
            initialValue: _baseExamInitialValue,
            items: defaultExams
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
                    FormBuilderValidators.min(1,
                        errorText: '시험 시간을 1 이상 입력해주세요.'),
                    FormBuilderValidators.max(300,
                        errorText: '시험 시간을 300 이하로 입력해주세요.'),
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
              child: const Text('추가'),
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
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: _buildForm(),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
