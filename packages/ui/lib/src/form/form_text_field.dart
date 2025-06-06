import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    required this.name,
    this.initialValue,
    this.hintText,
    this.suffixText,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.keyboardType,
    this.hideError = false,
    this.autoWidth = false,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.minLines,
    this.maxLines = 1,
  });

  final String name;
  final String? initialValue;
  final String? hintText;
  final String? suffixText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool hideError;
  final bool autoWidth;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String?>? onSubmitted;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final fieldWidget = FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      validator: validator,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      minLines: minLines,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        suffixText: suffixText,
        errorStyle: hideError ? const TextStyle(height: 0.001) : null,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.all(12),
        isCollapsed: true,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        disabledBorder: OutlineInputBorder(
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
      ),
    );

    if (autoWidth) {
      return IntrinsicWidth(child: fieldWidget);
    }

    return fieldWidget;
  }
}
