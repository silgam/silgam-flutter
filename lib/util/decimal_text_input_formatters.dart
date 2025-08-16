import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  const DecimalTextInputFormatter({this.decimalRange = 2});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    final RegExp regex = RegExp(r'^\d*\.?\d{0,' + decimalRange.toString() + r'}$');

    if (regex.hasMatch(newText)) {
      if (newText.split('.').length > 2) {
        return oldValue;
      }

      if (newText.startsWith('.')) {
        return oldValue;
      }

      return newValue;
    }

    return oldValue;
  }
}
