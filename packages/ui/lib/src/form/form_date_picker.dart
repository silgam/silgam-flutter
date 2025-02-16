import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class FormDatePicker extends StatelessWidget {
  const FormDatePicker({
    super.key,
    required this.name,
    this.initialValue,
    required this.firstDate,
    required this.lastDate,
    this.autoWidth = false,
  });

  final String name;
  final DateTime? initialValue;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool autoWidth;

  @override
  Widget build(BuildContext context) {
    final fieldWidget = FormBuilderField<DateTime>(
      name: name,
      initialValue: initialValue,
      builder: (field) {
        final value = field.value;
        final state = field
            as FormBuilderFieldState<FormBuilderField<DateTime>, DateTime>;

        return GestureDetector(
          onTap: state.enabled
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: value,
                    firstDate: firstDate,
                    lastDate: lastDate,
                  );
                  if (date == null) return;

                  field.didChange(date);
                }
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              isCollapsed: true,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.5, color: Colors.grey.shade300),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ),
            child: Text(
              value != null ? DateFormat.yMEd('ko_KR').format(value) : '',
              style: TextTheme.of(context).titleMedium?.copyWith(
                    color:
                        state.enabled ? null : Theme.of(context).disabledColor,
                  ),
            ),
          ),
        );
      },
    );

    if (autoWidth) {
      return IntrinsicWidth(child: fieldWidget);
    }

    return fieldWidget;
  }
}
