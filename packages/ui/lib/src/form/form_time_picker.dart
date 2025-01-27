import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class FormTimePicker extends StatelessWidget {
  const FormTimePicker({
    super.key,
    required this.name,
    this.initialValue,
  });

  final String name;
  final TimeOfDay? initialValue;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<TimeOfDay>(
      name: name,
      initialValue: initialValue,
      builder: (field) {
        final value = field.value;

        return GestureDetector(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: value ?? TimeOfDay.now(),
            );
            if (time == null) return;

            field.didChange(time);
          },
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
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        );
      },
    );
  }
}
