import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class FormTimePicker extends StatelessWidget {
  const FormTimePicker({
    super.key,
    required this.name,
    this.initialValue,
    this.autoWidth = false,
  });

  final String name;
  final TimeOfDay? initialValue;
  final bool autoWidth;

  @override
  Widget build(BuildContext context) {
    final fieldWidget = FormBuilderField<TimeOfDay>(
      name: name,
      initialValue: initialValue,
      builder: (field) {
        final value = field.value;
        final state = field
            as FormBuilderFieldState<FormBuilderField<TimeOfDay>, TimeOfDay>;

        return GestureDetector(
          onTap: state.enabled
              ? () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: value ?? TimeOfDay.now(),
                  );
                  if (time == null) return;

                  field.didChange(time);
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
              value != null
                  ? DateFormat.jm('ko_KR')
                      .format(DateTime(0, 0, 0, value.hour, value.minute))
                  : '',
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
