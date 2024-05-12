import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:silgam/presentation/custom_exam_list/custom_exam_list_page.dart';

class CustomExamEditPage extends StatefulWidget {
  static const routeName = '${CustomExamListPage.routeName}/edit';

  const CustomExamEditPage({super.key});

  @override
  State<CustomExamEditPage> createState() => _CustomExamEditPageState();
}

class _CustomExamEditPageState extends State<CustomExamEditPage> {
  static const _subjectNameFieldName = 'subjectName';
  static const _durationFieldName = 'duration';
  static const _numberOfQuestionsFieldName = 'numberOfQuestions';
  static const _perfectScoreFieldName = 'perfectScore';

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
    }
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

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      onWillPop: _onWillPop,
      onChanged: () {
        _isChanged = true;
      },
      child: ListView(
        children: [
          const SizedBox(height: 28),
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
          _buildLabel('시험 시작 시간'),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: const Text(
                // DateFormat.jm('ko_KR').format(_examStartedTime),
                '오전 10:00',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('시험 시간'),
          FormBuilderTextField(
            name: _durationFieldName,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '시험 시간을 입력해주세요.'),
              FormBuilderValidators.numeric(errorText: '숫자만 입력해주세요.'),
              FormBuilderValidators.min(1, errorText: '1 이상 입력해주세요.'),
              FormBuilderValidators.max(300, errorText: '300 이하로 입력해주세요.'),
            ]),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: defaultInputDecoration.copyWith(
              suffixText: '분',
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('문제 수'),
          FormBuilderTextField(
            name: _numberOfQuestionsFieldName,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '문제 수를 입력해주세요.'),
              FormBuilderValidators.numeric(errorText: '숫자만 입력해주세요.'),
              FormBuilderValidators.min(1, errorText: '1 이상 입력해주세요.'),
              FormBuilderValidators.max(300, errorText: '300 이하로 입력해주세요.'),
            ]),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: defaultInputDecoration.copyWith(
              suffixText: '문제',
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('만점'),
          FormBuilderTextField(
            name: _perfectScoreFieldName,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '만점을 입력해주세요.'),
              FormBuilderValidators.numeric(errorText: '숫자만 입력해주세요.'),
              FormBuilderValidators.min(1, errorText: '1 이상 입력해주세요.'),
              FormBuilderValidators.max(999, errorText: '999 이하로 입력해주세요.'),
            ]),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: defaultInputDecoration.copyWith(
              suffixText: '점',
            ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
