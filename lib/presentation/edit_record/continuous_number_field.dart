import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContinuousNumberField extends StatefulWidget {
  final Function(int) onSubmit;
  final Function() onDelete;
  final int maxDigits;

  const ContinuousNumberField({
    super.key,
    required this.onSubmit,
    required this.onDelete,
    this.maxDigits = 2,
  });

  @override
  State<ContinuousNumberField> createState() => _ContinuousNumberFieldState();
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
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        textInputAction: TextInputAction.next,
        onEditingComplete: () {
          // Required, prevent hiding keyboard
        },
        onChanged: _onTextFieldChanged,
        onSubmitted: _onSubmitted,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '번호 입력',
          hintStyle: const TextStyle(fontSize: 14),
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
            borderRadius: const BorderRadius.all(Radius.circular(100)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
            borderRadius: const BorderRadius.all(Radius.circular(100)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(100)),
          ),
        ),
      ),
    );
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _editingController.text.isEmpty) {
      widget.onDelete();
    }
  }

  void _onTextFieldChanged(String text) {
    if (text.endsWith(' ') ||
        text.endsWith('.') ||
        text.endsWith(',') ||
        text.length >= widget.maxDigits) {
      _onSubmitted(_editingController.text);
    }
  }

  void _onSubmitted(String text) {
    _editingController.clear();
    text = text.replaceAll('.', '');
    text = text.replaceAll(',', '');
    int inputNumber = int.tryParse(text) ?? -1;
    if (inputNumber <= 0) return;
    widget.onSubmit(inputNumber);
  }

  @override
  void dispose() {
    _keyListenerFocusNode.dispose();
    super.dispose();
  }
}
