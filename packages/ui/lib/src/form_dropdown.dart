import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormDropdown<T> extends StatelessWidget {
  const FormDropdown({
    super.key,
    required this.name,
    required this.items,
    this.initialValue,
    this.onChanged,
  });

  final String name;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown<T>(
      name: name,
      items: items,
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.all(12),
        isCollapsed: true,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
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
  }
}
