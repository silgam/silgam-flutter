import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContinuousNumberField extends StatefulWidget {
  final Function(int) onSubmit;
  final Function() onDelete;

  const ContinuousNumberField({
    Key? key,
    required this.onSubmit,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ContinuousNumberFieldState createState() => _ContinuousNumberFieldState();
}

class _ContinuousNumberFieldState extends State<ContinuousNumberField> {
  final FocusNode _keyListenerFocusNode = FocusNode();
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _keyListenerFocusNode.addListener(() {
      _onSubmitted(_editingController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _onKeyEvent,
      child: TextField(
        controller: _editingController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: '번호 입력',
          border: InputBorder.none,
        ),
        onEditingComplete: () {
          // Required, prevent hiding keyboard
        },
        onChanged: _onTextFieldChanged,
        onSubmitted: _onSubmitted,
      ),
    );
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.backspace && _editingController.text.isEmpty) {
      widget.onDelete();
    }
  }

  void _onTextFieldChanged(String text) {
    if (text.endsWith(' ') || text.endsWith('.') || text.endsWith(',') || text.length >= 2) {
      _onSubmitted(_editingController.text);
    }
  }

  void _onSubmitted(String text) {
    _editingController.clear();
    text = text.replaceAll('.', '');
    text = text.replaceAll(',', '');
    int inputNumber = int.tryParse(text) ?? -1;
    if (inputNumber == -1) return;
    widget.onSubmit(inputNumber);
  }

  @override
  void dispose() {
    _keyListenerFocusNode.dispose();
    super.dispose();
  }
}
