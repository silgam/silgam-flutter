import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silgam/presentation/custom_exam_list/custom_exam_list_page.dart';

class CustomExamEditPage extends StatefulWidget {
  static const routeName = '${CustomExamListPage.routeName}/edit';

  const CustomExamEditPage({super.key});

  @override
  State<CustomExamEditPage> createState() => _CustomExamEditPageState();
}

class _CustomExamEditPageState extends State<CustomExamEditPage> {
  final _formKey = GlobalKey<FormState>();
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

  Widget _buildNumberInput({
    required String label,
    required String suffix,
    required int maxLength,
    required double inputWidth,
    required FormFieldValidator validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          width: inputWidth,
          child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            validator: validator,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxLength),
            ],
            decoration: defaultInputDecoration.copyWith(
              suffixText: suffix,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      onWillPop: _onWillPop,
      onChanged: () {
        _isChanged = true;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          _buildLabel('과목 이름'),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '과목 이름을 입력해주세요.';
              }
              return null;
            },
            decoration: defaultInputDecoration.copyWith(
              hintText: '실감 하프 모의고사',
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
              _buildNumberInput(
                label: '시험 시간',
                suffix: '분',
                maxLength: 3,
                inputWidth: 75,
                validator: (value) => null,
              ),
              _buildNumberInput(
                label: '문제 수',
                suffix: '문제',
                maxLength: 3,
                inputWidth: 90,
                validator: (value) => null,
              ),
              _buildNumberInput(
                label: '만점',
                suffix: '점',
                maxLength: 3,
                inputWidth: 75,
                validator: (value) => null,
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
