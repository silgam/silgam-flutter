import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

typedef FormNumbersFieldNumberToString = String Function(int number);

class FormNumbersField extends StatefulWidget {
  const FormNumbersField({
    super.key,
    required this.name,
    this.initialValue = const [],
    this.hintText,
    this.maxDigits = 2,
    this.displayStringForNumber = defaultStringForNumber,
  });

  final String name;
  final List<int> initialValue;
  final String? hintText;
  final int maxDigits;
  final FormNumbersFieldNumberToString displayStringForNumber;

  @override
  State<FormNumbersField> createState() => _FormNumbersFieldState();

  static String defaultStringForNumber(int number) => number.toString();
}

class _FormNumbersFieldState extends State<FormNumbersField> {
  final GlobalKey<FormFieldState<List<int>>> _fieldKey = GlobalKey();

  void _onNumberSubmit(int number) {
    final field = _fieldKey.currentState;
    final newNumbers = [...?field?.value];

    if (newNumbers.contains(number)) {
      newNumbers
        ..remove(number)
        ..add(number);
    } else {
      newNumbers.add(number);
    }

    field?.didChange(newNumbers);
  }

  void _onNumberDelete([int? number]) {
    final field = _fieldKey.currentState;
    final newNumbers = [...?field?.value];

    if (number != null) {
      newNumbers.remove(number);
    } else {
      newNumbers.removeLast();
    }

    field?.didChange(newNumbers);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<int>>(
      key: _fieldKey,
      name: widget.name,
      initialValue: widget.initialValue,
      builder: (field) {
        final state =
            field
                as FormBuilderFieldState<
                  FormBuilderField<List<int>>,
                  List<int>
                >;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final number in field.value ?? [])
              _NumberItem(
                number: number,
                displayStringForNumber: widget.displayStringForNumber,
                onTap: state.enabled ? () => _onNumberDelete(number) : null,
              ),
            _NumberField(
              enabled: state.enabled,
              onSubmit: state.enabled ? _onNumberSubmit : null,
              onDelete: state.enabled ? _onNumberDelete : null,
              hintText: widget.hintText,
              maxDigits: widget.maxDigits,
            ),
          ],
        );
      },
    );
  }
}

class _NumberItem extends StatelessWidget {
  const _NumberItem({
    required this.number,
    required this.displayStringForNumber,
    this.onTap,
  });

  final int number;
  final FormNumbersFieldNumberToString displayStringForNumber;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: InputDecorator(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            isCollapsed: true,
            filled: true,
            fillColor: Theme.of(context).primaryColor,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(100),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(Icons.cancel, size: 18, color: Colors.white54),
            ),
            suffixIconConstraints: BoxConstraints(minWidth: 32),
          ),
          child: Text(
            displayStringForNumber(number),
            style: const TextStyle(fontSize: 17, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.enabled,
    this.onSubmit,
    this.onDelete,
    this.hintText,
    this.maxDigits = 2,
  });

  final bool enabled;
  final Function(int number)? onSubmit;
  final Function()? onDelete;
  final String? hintText;
  final int maxDigits;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
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
  void dispose() {
    _keyListenerFocusNode.dispose();
    _editingController.dispose();

    super.dispose();
  }

  void _onChanged(String text) {
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

    widget.onSubmit?.call(inputNumber);
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _editingController.text.isEmpty) {
      widget.onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyListenerFocusNode,
      onKeyEvent: _onKeyEvent,
      child: IntrinsicWidth(
        child: TextField(
          controller: _editingController,
          enabled: widget.enabled,
          onChanged: _onChanged,
          onSubmitted: _onSubmitted,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          textInputAction: TextInputAction.next,
          onEditingComplete: () {
            // Required, prevent hiding keyboard
          },
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(100),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(100),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: Colors.red),
              borderRadius: BorderRadius.circular(100),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: Colors.red),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}
